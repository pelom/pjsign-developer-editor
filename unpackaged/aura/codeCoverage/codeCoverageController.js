({
	doInit: function(component) {
	    console.log('component: ' + component);
	    var action = component.get("c.getCodeCovegare");
	    //action.setParams({ session : $Api.Session_ID });
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
                component.set("v.myObject", response);
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