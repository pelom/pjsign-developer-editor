({
	doInit: function(component) {
	    console.log('component: ' + component);

	    var getApexTestSuite = component.get('c.getApexTestSuite');
        //action.setParams({ session : $Api.Session_ID });
        getApexTestSuite.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var response = response.getReturnValue();
                console.log('response: ' + response);

                var testSuiteList = [];
                for(var key in response) {
                    console.log('key: ' + key);
                    console.log('response[Key]: ' + response[key].id);
                    testSuiteList.push(response[key]);
                }
                component.set('v.testSuiteMap', response);
                component.set('v.testSuiteList', testSuiteList);

            } else if (state === 'INCOMPLETE') {
                // do something
            } else if (state === 'ERROR') {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('Error message: ' + errors[0].message);
                    }
                } else {
                    console.log('Unknown error');
                }
            }
        });
        $A.enqueueAction(getApexTestSuite);

	    var action = component.get("c.getCodeCovegare");
	    //action.setParams({ session : $Api.Session_ID });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('response.getReturnValue(): ' + response);

//                for(var key in response) {
//                    var obj = response[key];
//
//                    console.log('Object')
//                    console.log('property' + Object.getOwnPropertyNames(response[key]));
//                    var propertyList = Object.getOwnPropertyNames(obj);
//                    for(var property in propertyList) {
//                        var field = propertyList[property];
//                        console.log('field: ' + field, 'value: ' +  obj[field]);
//                    }
//                }
                component.set("v.codeCovegareList", response);
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
    },

    showTestSuiteList: function(component) {
        console.log('showTestSuiteList(): ' + component);

        var testSuiteDropdown = component.find('testSuiteDropdown');
        if($A.util.hasClass(testSuiteDropdown, 'slds-is-open')) {
            $A.util.removeClass(testSuiteDropdown, 'slds-is-open');
        } else {
            $A.util.addClass(testSuiteDropdown, 'slds-is-open');
        }
    },

    selectTestSuite: function(component, event) {
        console.log('selectTestSuite(): ' + event);

        var selectedItem = event.currentTarget;
        var value = selectedItem.dataset.value;

        var action = component.get("c.getCodeCovegare");
        action.setParams({ testSuiteId : value });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('response.getReturnValue(): ' + response);
                component.set("v.codeCovegareList", response);

                console.log(value);
                var input = component.find('testSuiteInput');
                var testSuiteList = component.get('v.testSuiteList');

                for(var i = 0; i < testSuiteList.length; i++) {
                    testSuiteList[i].select = false;

                    if(testSuiteList[i].id === value) {
                        testSuiteList[i]['select'] = true;
                        input.set("v.value", testSuiteList[i].name);
                    }
                }

                var testSuiteDropdown = component.find('testSuiteDropdown');
                if($A.util.hasClass(testSuiteDropdown, 'slds-is-open')) {
                    $A.util.removeClass(testSuiteDropdown, 'slds-is-open');
                } else {
                    $A.util.addClass(testSuiteDropdown, 'slds-is-open');
                }
                component.set('v.testSuiteList', testSuiteList);
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