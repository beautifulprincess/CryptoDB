$(document).ready(function(){
    web3.eth.getBalance("0xB5b1317ecDa0369944d90221e6bFb9BF301BAd39", "latest", function(resp){
        console.log(resp);
    });
});