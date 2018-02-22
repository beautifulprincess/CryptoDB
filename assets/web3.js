var web3 = {
    version: "2.0",
    id: 0,
    provider_url: "",
    provider_port: "",
    request: function(method, params, callback) {
        var data = {};
        data.jsonrpc = this.version;
        data.id = this.id++;
        data.method = method;
        data.params = params;

        var provider = this.provider_url;
        if (this.provider_port) provider += ":" + this.provider_port;

        var xhr = new XMLHttpRequest();
        xhr.open("POST", provider, true);

        xhr.setRequestHeader("Content-type", "application/json");

        xhr.onreadystatechange = function() {//Call a function when the state changes.
            if(xhr.readyState == XMLHttpRequest.DONE && xhr.status == 200) {
                // Request finished. Do processing here.
                callback(xhr.responseText);
            }
        }
        xhr.send(JSON.stringify(data));
    },
    setProvider: function(provider_url, provider_port) {
        this.provider_url = provider_url;
        if (provider_port) this.provider_port = provider_port;
        else this.provider_port = "";
    },
    eth: {
        getBalance: function(address, block, callback) {
            web3.request("eth_getBalance", [address, block], callback);
        }
    }
};