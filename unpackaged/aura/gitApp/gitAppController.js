({
	myAction : function(component, event, helper) {
		console.log('Oláaa');
	},

	toggle : function(component, event, helper) {
        var menu = component.find("nav-menu");

        console.log('Menu: ' + menu.length);
        for(var i = 0; i < menu.length; i++) {
            $A.util.toggleClass(menu[i], "toggle");
        }

    },

    toggleSpinner: function(cmp) {
        console.log('toggleSpinner()');

        var spinner = cmp.find('spinner');
        console.log('spinner: ' + spinner);
        console.log('hasClass: ' + $A.util.hasClass(spinner, 'toggle'));
        if($A.util.hasClass(spinner, 'toggle')){
            $A.util.removeClass(spinner, 'toggle');

        } else {
            $A.util.addClass(spinner, 'toggle');
        }
     },

    onClickMenu: function(component, event, helper) {
        console.log('onClickMenu() component:' + component );

        var toggleSpinner = component.get('c.toggleSpinner');
        $A.enqueueAction(toggleSpinner);

        var menuItemId = 'nav-menu-li';
        var styleClass = 'slds-is-active';

        var menuItem = component.find(menuItemId);
        for(var i = 0; i < menuItem.length; i++) {
            $A.util.removeClass(menuItem[i].getElement(), styleClass);
        }

        var selectedItem = event.currentTarget;
        $A.util.addClass(selectedItem, styleClass);

        var action = selectedItem.dataset.action;
        if ($A.util.isEmpty(action)) {
            return;
        }
        action = 'c:' + action;
        $A.createComponent(
            action, { "aura:id": action, }, function(newComponent, status, errorMessage) {
                component.set("v.body", []);
                var toggleSpinner = component.get('c.toggleSpinner');
                $A.enqueueAction(toggleSpinner);

                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    }

})