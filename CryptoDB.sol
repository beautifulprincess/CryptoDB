pragma solidity ^0.4.18;

contract CryptoDB {
    struct CDatabase {
        bytes32 dbname;
        uint created;
    }
    struct CTable {
        bytes32 dbname;
        bytes32 tbname;
        uint created;
    }
    struct CValue {
        bytes32 dbname;
        bytes32 tbname;
        bytes32 fdname;
        bytes32 cvalue;
        bytes32 id;
        uint created;
    }
    
    mapping(address => CDatabase[]) databases;
    mapping(address => CTable[]) tables;
    mapping(address => CValue[]) values;

    //constructor
    function CryptoDB() public {
        
    }
    
    function stringsEqual(string _a, string _b) internal returns (bool) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}
	
	function uintToString(uint v) internal constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }
	
    function removeDB(CDatabase[] array, uint index) internal returns(CDatabase[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }
	
    function removeTB(CTable[] array, uint index) internal returns(CTable[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }
	
    function removeCV(CValue[] array, uint index) internal returns(CValue[]) {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++){
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }
    
    function createDatabase(bytes32 dbname) public {
        for(uint i = 0; i < databases[msg.sender].length; i++) {
            require (dbname != databases[msg.sender][i].dbname);
        }
        CDatabase memory cdb = CDatabase(
            {
                dbname: dbname,
                created: now
            }
        );
        
        databases[msg.sender].push(cdb);
    }
    
    function createTable(bytes32 dbname, bytes32 tbname) public {
        for(uint i = 0; i < tables[msg.sender].length; i++) {
            require (dbname != tables[msg.sender][i].dbname || tbname != tables[msg.sender][i].tbname);
        }
        CTable memory ctb = CTable(
            {
                dbname: dbname,
                tbname: tbname,
                created: now
            }
        );
        
        tables[msg.sender].push(ctb);
    }
    
    function insertValue(bytes32 dbname, bytes32 tbname, bytes32 id, bytes32 fdname, bytes32 cvalue) public {
        CValue memory cv = CValue(
            {
                dbname: dbname,
                tbname: tbname,
                id: id,
                fdname: fdname,
                cvalue: cvalue,
                created: now
            }
        );
        
        values[msg.sender].push(cv);
    }
    
    function updateValue(bytes32 dbname, bytes32 tbname, bytes32 id, bytes32 fdname, bytes32 cvalue) public {
        for(uint i = 0; i < values[msg.sender].length; i++) {
            if (dbname == values[msg.sender][i].dbname && tbname == values[msg.sender][i].tbname && id == values[msg.sender][i].id && fdname == values[msg.sender][i].fdname) {
                values[msg.sender][i].cvalue = cvalue;
                return;
            }
        }
    }
    
    function deleteValue(bytes32 dbname, bytes32 tbname, bytes32 id, bytes32 fdname) public {
        for(uint i = 0; i < values[msg.sender].length; i++) {
            if (dbname == values[msg.sender][i].dbname && tbname == values[msg.sender][i].tbname && id == values[msg.sender][i].id && fdname == values[msg.sender][i].fdname) {
                removeCV(values[msg.sender], i);
                return;
            }
        }
    }
    
    function deleteRecord(bytes32 dbname, bytes32 tbname, bytes32 id) public {
        for(uint i = values[msg.sender].length - 1; i >= 0; i--) {
            if (dbname == values[msg.sender][i].dbname && tbname == values[msg.sender][i].tbname && id == values[msg.sender][i].id) {
                removeCV(values[msg.sender], i);
            }
        }
    }
    
    function dropTable(bytes32 dbname, bytes32 tbname) public {
        for(uint i = values[msg.sender].length - 1; i >= 0; i--) {
            if (dbname == values[msg.sender][i].dbname && tbname == values[msg.sender][i].tbname) {
                removeCV(values[msg.sender], i);
            }
        }
        for(i = 0; i < tables[msg.sender].length; i++) {
            if (dbname == tables[msg.sender][i].dbname && tbname == tables[msg.sender][i].tbname) {
                removeTB(tables[msg.sender], i);
                return;
            }
        }
    }
    
    function dropDatabase(bytes32 dbname) public {
        for(uint i = values[msg.sender].length - 1; i >= 0; i--) {
            if (dbname == values[msg.sender][i].dbname) {
                removeCV(values[msg.sender], i);
            }
        }
        for(i = tables[msg.sender].length - 1; i >= 0; i--) {
            if (dbname == tables[msg.sender][i].dbname) {
                removeTB(tables[msg.sender], i);
            }
        }
        for(i = 0; i < databases[msg.sender].length; i++) {
            if (dbname == databases[msg.sender][i].dbname) {
                removeDB(databases[msg.sender], i);
                return;
            }
        }
    }
    
    function getDatabases() public view returns (bytes32[]) {
        bytes32[] storage dbs;
        for(uint i = 0; i < databases[msg.sender].length; i++) {
            dbs.push(databases[msg.sender][i].dbname);
        }
        return dbs;
    }
    
    function getTables(bytes32 dbname) public view returns (bytes32[]) {
        bytes32[] storage tbs;
        for(uint i = 0; i < tables[msg.sender].length; i++) {
            if (tables[msg.sender][i].dbname == dbname) {
                tbs.push(tables[msg.sender][i].dbname);
            }
        }
        return tbs;
    }
    
    function getAllRecords(bytes32 dbname, bytes32 tbname) public view returns (bytes32[]) {
        bytes32[] storage res;
        for(uint i = 0; i < values[msg.sender].length; i++) {
            if (values[msg.sender][i].dbname == dbname && values[msg.sender][i].tbname == tbname) {
                res.push(values[msg.sender][i].id);
                res.push(values[msg.sender][i].fdname);
                res.push(values[msg.sender][i].cvalue);
            }
        }
        return res;
    }
    
    function getOneRecord(bytes32 dbname, bytes32 tbname, bytes32 id) public view returns (bytes32[]) {
        bytes32[] storage res;
        for(uint i = 0; i < values[msg.sender].length; i++) {
            if (values[msg.sender][i].dbname == dbname && values[msg.sender][i].tbname == tbname && values[msg.sender][i].id == id) {
                res.push(values[msg.sender][i].id);
                res.push(values[msg.sender][i].fdname);
                res.push(values[msg.sender][i].cvalue);
            }
        }
        return res;
    }
}