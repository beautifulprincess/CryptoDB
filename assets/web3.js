var web3 = {
    version: "2.0",
    id: 0,
    request: function(method, params, callback) {
        var data = {};
        data.jsonrpc = this.version;
        data.id = this.id++;
        data.method = method;
        data.params = params;

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "https://mainnet.infura.io", true);

        xhr.setRequestHeader("Content-type", "application/json");

        xhr.onreadystatechange = function() {//Call a function when the state changes.
            if(xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200) {
                // Request finished. Do processing here.
                callback(xhr.responseText);
            }
        }
        xhr.send(JSON.stringify(data));
    },
    eth: {
        getBalance: function(address, block, callback) {
            web3.request("eth_getBalance", [address, block], callback);
        }
    }
};