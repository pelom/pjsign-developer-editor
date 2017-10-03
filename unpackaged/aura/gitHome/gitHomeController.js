({
	echo: function(cmp) {
//	    var action = cmp.get("c.serverEcho");
//        action.setParams({ firstName : cmp.get("v.firstName") });
//        action.setBackground();
//        $A.enqueueAction(action);

        var action = cmp.get("c.serverEcho");
        action.setParams({ firstName : cmp.get("v.firstName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned
                // from the server
                alert("From server: " + response.getReturnValue());

                // You would typically fire a event here to trigger
                // client-side notification that the server-side
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

        action = cmp.get("c.getAccounts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('response.getReturnValue(): ' + response);

                for(var key in response) {
                    var obj = response[key];

                    console.log('Object')
                    console.log('property' + Object.getOwnPropertyNames(response[key]));
                    var propertyList = Object.getOwnPropertyNames(obj);
                    for(var property in propertyList) {
                        var field = propertyList[property];
                        console.log('field: ' + field, 'value: ' +  obj[field]);
                    }
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})