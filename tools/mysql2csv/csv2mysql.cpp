/**
 * Excute a MySQL query with each row read from the csv file except the header row.
 * The csv format used here comforms to [rfc4180](http://tools.ietf.org/html/rfc4180).
 * @author roxma
 */

#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <cstddef>

class CsvReader{

	std::istream* pIstream;

	// from http://stackoverflow.com/questions/5343190
	std::string ReplaceString(
			  std::string subject
			, const std::string& search
			, const std::string& replace) {
    		size_t pos = 0;
    		while ((pos = subject.find(search, pos)) != std::string::npos) {
			subject.replace(pos, search.length(), replace);
			pos += replace.length();
		}
    		return subject;
	}

	enum CellEnd{
		  EndOfCell
		, EndOfRow
		, EndOfFile
		
		, EndUnInit
	};

	/**
	 * @return error code
	 */
	int ReadCell(std::string& o_value,CellEnd& o_cellEnd){
		int isInQuotes = 0;
		int lastCh= 'a'; // use to detect '"' and '\r' character
		size_t i = 0;
		for(int ch = this->pIstream->get(); this->pIstream->fail()==0; lastCh = ch, ch = this->pIstream->get(),++i){
			if(isInQuotes){
				if(ch=='\"'){
					isInQuotes = 0;
					continue;
				}
				o_value += ((char)ch);
				continue;
			}else{

				if( (lastCh=='\r') && (ch != '\n') ){
					// Fields containing line breaks (CRLF), double quotes, and commas
					// should be enclosed in double-quotes.
					return __LINE__; 				
				}

				if(ch=='\"'){
					if(lastCh=='\"'){ // escaped
						o_value += ((char)ch);
						isInQuotes = 1;
						continue;
					}
					if(i!=0){ 
						// Fields containing line breaks (CRLF), double quotes, and commas
						// should be enclosed in double-quotes.
						return __LINE__;
					}
					isInQuotes = 1;
					continue;
				}

				if(ch=='\r'){
					continue;
				}
				if(ch=='\n'){
					if(lastCh != '\r'){
						// Fields containing line breaks (CRLF), double quotes, and commas
						// should be enclosed in double-quotes.
						return __LINE__;
					}
					o_cellEnd = EndOfRow;
					return 0;
				}

				if(ch==','){
					o_cellEnd = EndOfCell;
					return 0;
				}

				if(lastCh=='\"'){
					return __LINE__;
				}
				o_value += ((char)ch);
				continue;
			}
		}
		if(this->pIstream->eof()){
			o_cellEnd = EndOfFile;
			return 0;
		}
		return __LINE__; // stream error
	}

public:

	/**
	 * @note If this function reads 0 element and returns success, we've reached the
	 *     end of the file.
	 */
	int ReadRow(std::vector<std::string>& oRow){
		CellEnd end =  EndUnInit;
		int readCellErr = 0;
		oRow.clear();
		for(std::string value; (readCellErr=ReadCell(value,end))==0 ;value.clear()){
			if((value.length()==0) && (oRow.size()==0) && (end!=EndOfCell)){
				if (end!=EndOfFile){
					// Within the header and each record, there may be one or more
					// fields
					return __LINE__;
				}
				break;
			}
			oRow.push_back(value);
			if(end != EndOfCell){
				break;
			}
		}
		return readCellErr;
	}

	/**
 	 * @param ir_stream [in ref] 
 	 * @note The stream should be opened in binary mode.
 	 */
	CsvReader(std::istream* ir_stream):pIstream(ir_stream){}

};

#include <string.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <cctype>


#include <mysql/mysql.h>

void ShowUsage(const std::map<std::string,std::string>& i_args){
	std::cerr<<"usage: this_bin ";
	for(std::map<std::string,std::string>::const_iterator it=i_args.begin(); it!=i_args.end(); ++it){
		std::cerr<< it->first <<"=["<< it->first<<"] ";
	}
	std::cerr<<std::endl;
}

int ProcessArgs(int i_argc, char ** i_argv, std::map<std::string,std::string>& io_strArgs, std::map<std::string,int>& io_intArgs, std::string& o_errorMessage){
	if(i_argc<=1){
		o_errorMessage = "no arguments";
		ShowUsage(io_strArgs);
		return __LINE__;
	}
	
	for(int i=1; i<i_argc; ++i){
		std::string strPair = i_argv[i];
		
		// get key and value
		std::string::size_type pos = strPair.find_first_of("=");
		if(pos == std::string::npos){
			o_errorMessage = "Invalid parameter string \""+strPair+"\", it shoud be in this format \"key=value\"";
			return __LINE__;
		}
		std::string key = strPair.substr(0, pos);
		std::string value = strPair.substr(pos+1,strPair.length()-1-key.length());
		std::clog<<key<<"="<<value<<std::endl;
		
		if(io_strArgs.count(key)>0){
			io_strArgs[key] = value;
			continue;
		}

		if(io_intArgs.count(key)>0){
			std::istringstream iss(value);
			int intValue = 0;
			iss >> intValue;
			if(iss.fail()){
				o_errorMessage = "The parameter [" + key + "] should be an integer";
				return __LINE__;
			}
			io_intArgs[key] = intValue;
			continue;
		}
		
		o_errorMessage = "The parameter [" + key + "] is not supported";
		return __LINE__;
	}
	
	return 0;
}

int main(int argc,char**argv){

	std::map<std::string,std::string> args;
	std::map<std::string,int> intArgs;
	args["host"] = "127.0.0.1";
	intArgs["port"] = 3306;
	args["user"] = "root";
	args["passwd"] = "";
	args["charset"] = "utf8";

	args["db"] = "";
	args["execute"] = "";
	intArgs["begin_row_index"] = 1;
	//intArgs["transaction"] = 1;
	//intArgs["ignore_error"] = 0;
	
	args["null_cell_value"] = "NULL";
	
	args["input"] = "";


	std::string errorMessage;
	int errorCode = ProcessArgs(argc,argv,args,intArgs,errorMessage);
	if(errorCode){
		std::cerr<<"ERROR "<<errorCode<<": "<<errorMessage<<std::endl;
		return errorCode;
	}

	
	// open output stream
	std::istream* pStream = NULL;
	std::ifstream file;
	if(args["input"] != ""){
		file.open(args["input"].c_str(),std::ifstream::binary);
		if(!file){
			std::cout<<"ERROR: cannot open file ["<<args["input"]<<"]";
			return __LINE__;
		}
		pStream = &file;
	}else{
		pStream = &std::cin;
	}

	CsvReader reader(pStream);

	// debugging
	//std::vector<std::string> row;
	//int rowIndex = 0;
	//for(reader.ReadRow(row); row.size(); row.clear(),reader.ReadRow(row)){
	//	std::cout<<"rowIndex = "<<rowIndex<<std::endl;
	//	for(int colIndex=0; colIndex<row.size(); ++colIndex){
	//		std::cout<<row[colIndex]<<std::endl;
	//	}
	//	rowIndex++;
	//}
	//return 0;

	
	MYSQL mysql;
	mysql_init(&mysql);

	// connection
	int charsetErr = mysql_options(&mysql,MYSQL_SET_CHARSET_NAME,args["charset"].c_str());
	if(charsetErr){
		std::cerr<<"ERROR : cannot set connection charset"<<std::endl;
		return __LINE__;
	}
	MYSQL* connectSuccess = mysql_real_connect(&mysql,args["host"].c_str(),args["user"].c_str(),args["passwd"].c_str(),args["db"].c_str(),intArgs["port"],NULL,0);
	if(connectSuccess==NULL){
		std::cerr<<"ERROR : cannot connect to mysql."<<std::endl;
		return __LINE__;
	}
	struct MySqlCloser{
		MYSQL *p;
		MySqlCloser(MYSQL* or_p):p(or_p){}
		~MySqlCloser(){mysql_close(p);}
	}mysqlCloser(&mysql);
	(void)mysqlCloser; // suppress warning

	// read header
	std::vector<std::string> header;
	std::map<std::string,size_t> headerIndexMap;
	int readHeaderErr = reader.ReadRow(header);
	if(readHeaderErr){
		std::cerr<<"ERROR : read header error."<<readHeaderErr<<std::endl;
		return __LINE__;
	}
	if(header.size()==0){
		std::cerr<<"ERROR : empty csv file.";
		return __LINE__;
	}
	for(size_t i=0; i<header.size(); ++i){
		headerIndexMap[header[i]] = i;
	}

	std::vector<std::string> fieldList;
	std::vector<MYSQL_BIND> params;
	std::string statement;
	if(args["execute"].length()==0){
		std::cerr<<"ERROR: parameter execute should not be empty."<<std::endl;
		return __LINE__;
	}
	for(std::istringstream iss(args["execute"]);;){

		char ch = iss.get();
		if(iss.eof()){
			break;
		}
		if(iss.fail()){
			std::cerr<<"ERROR: unknown error."<<__LINE__<<std::endl;
			return __LINE__;
		}
		statement += ch;
		if(ch!='?'){
			continue;
		}
		
		// extract "field" from "?field "
		std::string fieldName;
		for(;;){
			int fieldNameCh = iss.get();
			if((fieldName.length()==0) && iss.eof()){
				std::cerr<<"ERROR: execute["<<args["execute"]<<"] syntax error."<<std::endl;
				return __LINE__;
			}
			if(iss.eof()) break;
			if(iss.fail()){
				std::cerr<<"ERROR: unknown error."<<__LINE__<<std::endl;
				return __LINE__;
			}
			if( !std::isalnum(fieldNameCh) && (fieldNameCh!='_')){
				statement += fieldNameCh;
				break;
			}
			fieldName += fieldNameCh;
		}

		fieldList.push_back(fieldName);
	}
	params.resize(fieldList.size());
	for(size_t i=0; i<params.size(); ++i){
		memset ((void *) &(params[i]), 0, sizeof (params[i]));
	}
	// debugging
	while(0){
		std::clog<<"statement:"<<statement<<std::endl;
		for(int i=0; i<fieldList.size(); ++i){
			std::clog<<fieldList[i]<<std::endl;
		}
		return 0;
	}

	//start transaction
	if (mysql_query (&mysql,"begin")!=0){
		std::cerr<<"begin trasaction error."<<std::endl;
		return __LINE__;
	}

	MYSQL_STMT *stmt = mysql_stmt_init(&mysql);
	if(stmt==NULL){
		std::cerr<<"ERROR: could not initialize statement handler";
		return __LINE__;
	}
	struct StmtCloser{
		MYSQL_STMT *stmt;
		StmtCloser(MYSQL_STMT* or_stmt):stmt(or_stmt){}
		~StmtCloser(){mysql_stmt_close(stmt);}
	}stmtCloser(stmt);
	(void)stmtCloser; // suppress warning
	
	if( mysql_stmt_prepare (stmt, statement.c_str(),statement.length()) != 0){
		std::cerr<<"ERROR: Could not prepare statement, "<<mysql_stmt_error (stmt)<<std::endl;
		return __LINE__;
	}
	
	std::vector<std::string> row;
	for(reader.ReadRow(row); row.size(); row.clear(),reader.ReadRow(row)){
		if(row.size() < header.size()){
			std::cerr<<"invalid row"<<std::endl;
			return __LINE__;
		}
		
		for(size_t i=0; i<fieldList.size(); ++i){
			params[i].buffer_type = MYSQL_TYPE_STRING;
			params[i].buffer_length = row[headerIndexMap[fieldList[i]]].length();
			params[i].buffer = (void*)row[headerIndexMap[fieldList[i]]].c_str();
			params[i].is_null = 0;
		}
		if (mysql_stmt_bind_param (stmt, &(params[0])) != 0){
			std::cerr<<"ERROR: could not bind."<<std::endl;
			return __LINE__;
		}
		if (mysql_stmt_execute (stmt) != 0){
			std::cerr<<"ERROR: execute error."<<std::endl;
			return __LINE__;
		}
	}
	

	if (mysql_query (&mysql,"commit")!=0){
		std::cerr<<"commit trasaction error."<<std::endl;
		return __LINE__;
	}

	file.close();

	return 0;
}

