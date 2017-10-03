<aura:application extends="force:slds" >
    <aura:html tag="div"/>

    <div class="slds-grid slds-grid--frame slds-grid--vertical">

        <!-- Header -->
        <header class="header slds-size--1-of-1" role="banner">

            <div class="slds-grid">

                <div aura:id="nav-menu"
                     class="stage-left slds-grid slds-size--2-of-12  slds-theme--info slds-p-vertical--x-small slds-p-horizontal--medium">
                    <span class="slds-icon__container slds-align-middle">
                      <img onclick="{!c.toggle}" class="slds-icon slds-icon--small cursor-point"
                           src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/8005/rows.svg" alt="Toggle Menu" />
                      <span class="slds-assistive-text">Toggle Menu</span>
                    </span>
                </div>

                <div class="slds-grid slds-grow">
                    <a href="javascript:void(0);" class="slds-assistive-text slds-assistive-text_focus">Skip to Navigation</a>
                    <a href="javascript:void(0);" class="slds-assistive-text slds-assistive-text_focus">Skip to Main Content</a>

                    <div class="slds-p-vertical--x-small slds-p-horizontal--medium">
                        <img onclick="{!c.toggle}" class="cursor-point"
                             src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/8005/salesforce-logo.png" style="height: 45px;"/>
                    </div>

                    <div class="slds-global-header__item slds-global-header__item_search">
                        <div aria-expanded="false" aria-haspopup="listbox" class="slds-form-element slds-lookup"
                             role="combobox" style="margin-top: 15px;">

                            <label class="slds-assistive-text" for="global-search-01">Search Salesforce</label>

                            <div class="slds-form-element__control slds-input-has-icon slds-input-has-icon_left-right">

                                <div aura:id="icon-svg">
                                    <![CDATA[<svg class="slds-input__icon slds-input__icon_left" aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="{!$Resource.SLDS231 + '/assets/icons/utility-sprite/svg/symbols.svg#search'}"/>
                                    </svg>]]>
                                </div>

                                <input type="text" aria-activedescendant="" aria-autocomplete="list"
                                       aria-controls="global-search-list-01" autocomplete="off"
                                       class="slds-input slds-lookup__search-input" id="global-search-01"
                                       placeholder="Search Salesforce" role="textbox"/>
                            </div>

                            <div class="slds-lookup__menu" role="listbox" id="global-search-list-01">
                                <ul class="slds-lookup__list" role="group" aria-label="Recent Items">
                                    <li role="presentation">
                                        <h3 role="presentation" class="slds-lookup__item_label slds-text-body_small">
                                            Recent Items</h3>
                                    </li>

                                    <li role="presentation">
                                        <span class="slds-lookup__item-action slds-media" id="option-01" role="option">
                                            <div aura:id="icon-svg">
                                                <![CDATA[<svg class="slds-icon slds-icon-standard-opportunity slds-icon_small slds-media__figure"
                                                              aria-hidden="true">
                                                    <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                                         xlink:href="{!$Resource.SLDS231 +
                                                                 '/assets/icons/standard-sprite/svg/symbols.svg#opportunity'}"/>
                                                </svg>]]>
                                            </div>
                                            <span class="slds-media__body">
                                                <span class="slds-lookup__result-text">Salesforce - 1,000 Licenses</span>
                                                <span class="slds-lookup__result-meta slds-text-body_small">Opportunity ? Prospecting</span>
                                            </span>
                                        </span>
                                    </li>

                                    <li role="presentation">
                                        <span class="slds-lookup__item-action slds-media" id="option-02" role="option">

                                             <![CDATA[<svg class="slds-icon slds-icon-standard-contact slds-icon_small slds-media__figure"
                                                           aria-hidden="true">
                                                <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                                     xlink:href="/assets/icons/standard-sprite/svg/symbols.svg#contact"/>
                                            </svg>]]>

                                            <span class="slds-media__body">
                                                <span class="slds-lookup__result-text">Art Vandelay</span>
                                                <span class="slds-lookup__result-meta slds-text-body_small">Contact ? avandelay@vandelay.com</span>
                                            </span>
                                        </span>
                                    </li>

                                    <li role="presentation">
                                <span class="slds-lookup__item-action slds-media" id="option-03" role="option">

                                 <![CDATA[<svg class="slds-icon slds-icon-standard-account slds-icon_small slds-media__figure"
                                               aria-hidden="true">
                                    <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                         xlink:href="/assets/icons/standard-sprite/svg/symbols.svg#account"/>
                                </svg>]]>

                                <span class="slds-media__body">
                                    <span class="slds-lookup__result-text">Vandelary Industries</span>
                                    <span class="slds-lookup__result-meta slds-text-body_small">Account ? San Francisco</span>
                                </span>
                                </span>
                                    </li>
                                    <li role="presentation">
                                <span class="slds-lookup__item-action slds-media" id="option-04" role="option">

                                     <![CDATA[<svg class="slds-icon slds-icon-custom-8 slds-icon_small slds-media__figure"
                                                   aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="/assets/icons/custom-sprite/svg/symbols.svg#custom8"/>
                                    </svg>]]>

                                    <span class="slds-media__body">
                                        <span class="slds-lookup__result-text">Salesforce UK 2016 Events</span>
                                        <span class="slds-lookup__result-meta slds-text-body_small">General Ledger ? $20,000</span>
                                    </span>
                                </span>
                                    </li>
                                    <li role="presentation">
                                <span class="slds-lookup__item-action slds-media" id="option-05" role="option">
                                     <![CDATA[<svg class="slds-icon slds-icon-standard-lead slds-icon_small slds-media__figure"
                                                   aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="/assets/icons/standard-sprite/svg/symbols.svg#lead"/>
                                    </svg>]]>

                                    <span class="slds-media__body">
                                        <span class="slds-lookup__result-text">H.E. Pennypacker</span>
                                        <span class="slds-lookup__result-meta slds-text-body_small">Lead ? Nursing</span>
                                    </span>
                                </span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="slds-grid slds-grow slds-grid_align-end">
                        <ul class="slds-global-header__item slds-grid slds-grid_vertical-align-center">
                            <li class="slds-grid">
                                <button class="slds-button slds-button_icon slds-button_icon slds-button_icon-container slds-button_icon-small slds-global-header__button_icon-favorites"
                                        aria-pressed="false" title="Toggle Favorites">

                                    <div aura:id="icon-svg">
                                        <![CDATA[<svg class="slds-button__icon slds-global-header__icon" aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="{!$Resource.SLDS231 +
                                                     '/assets/icons/utility-sprite/svg/symbols.svg#favorite'}"/>
                                    </svg>]]>
                                    </div>
                                    <span class="slds-assistive-text">Toggle Favorite</span>
                                </button>
                                <span class="slds-dropdown-trigger slds-dropdown-trigger_click">
                            <button class="slds-button slds-button_icon slds-button_icon slds-button_icon-container slds-button_icon-small slds-global-header__button_icon slds-m-left_none"
                                    title="View Favorites">

                            <div aura:id="icon-svg">
                                <![CDATA[<svg class="slds-button__icon" aria-hidden="true">
                                    <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                         xlink:href="{!$Resource.SLDS231 +
                                                 '/assets/icons/utility-sprite/svg/symbols.svg#chevrondown'}"/>
                                </svg>]]>
                            </div>
                            <span class="slds-assistive-text">View Favorites</span>
                                    </button>
                                </span>
                            </li>

                            <li class="slds-dropdown-trigger slds-dropdown-trigger_click slds-p-horizontal_xxx-small">
                                <button class="slds-button slds-button_icon slds-button_icon slds-button_icon-small slds-button_icon-container slds-button_icon-x-small slds-global-header__button_icon-actions slds-m-horizontal_xx-small"
                                        title="Global Actions">

                                    <div aura:id="icon-svg">
                                        <![CDATA[<svg class="slds-button__icon" aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="{!$Resource.SLDS231 +
                                                     '/assets/icons/utility-sprite/svg/symbols.svg#add'}"/>
                                    </svg>]]>
                                    </div>
                                    <span class="slds-assistive-text">Global Actions</span>
                                </button>
                            </li>

                            <li class="slds-dropdown-trigger slds-dropdown-trigger_click">
                                <button class="slds-button slds-button_icon slds-button_icon slds-button_icon-container slds-button_icon-small slds-global-header__button_icon"
                                        title="Help and Training">

                                    <div aura:id="icon-svg">
                                        <![CDATA[<svg class="slds-button__icon slds-global-header__icon" aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="{!$Resource.SLDS231 +
                                                     '/assets/icons/utility-sprite/svg/symbols.svg#question'}"/>
                                    </svg>]]>
                                    </div>
                                    <span class="slds-assistive-text">Help and Training</span>
                                </button>
                            </li>

                            <li class="slds-dropdown-trigger slds-dropdown-trigger_click">
                                <button class="slds-button slds-button_icon slds-button_icon slds-button_icon-container slds-button_icon-small slds-global-header__button_icon"
                                        title="Setup">
                                    <div aura:id="icon-svg">
                                        <![CDATA[<svg class="slds-button__icon slds-global-header__icon" aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="{!$Resource.SLDS231 +
                                                     '/assets/icons/utility-sprite/svg/symbols.svg#setup'}"/>
                                    </svg>]]>
                                    </div>
                                    <span class="slds-assistive-text">Setup</span>
                                </button>
                            </li>

                            <li class="slds-dropdown-trigger slds-dropdown-trigger_click">
                                <button class="slds-button slds-button_icon slds-button_icon slds-button_icon-container slds-button_icon-small slds-global-header__button_icon"
                                        title="Notifications">
                                    <div aura:id="icon-svg">
                                        <![CDATA[<svg class="slds-button__icon slds-global-header__icon" aria-hidden="true">
                                        <use xmlns:xlink="http://www.w3.org/1999/xlink"
                                             xlink:href="{!$Resource.SLDS231 +
                                                     '/assets/icons/utility-sprite/svg/symbols.svg#notification'}"/>
                                    </svg>]]>
                                    </div>
                                    <span class="slds-assistive-text">Notifications</span>
                                </button>
                            </li>

                            <li class="slds-dropdown-trigger slds-dropdown-trigger_click slds-m-left_x-small">
                                <button class="slds-button" title="person name" aria-haspopup="true">
                            <span class="slds-avatar slds-avatar_circle slds-avatar_medium">
                                <img alt="Person name" src="{!$Resource.SLDS231 +
                                        '/assets/images/avatar2.jpg'}" title="User avatar"/>
                            </span>
                                </button>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>

        </header>

        <!-- Stage Container -->
        <div  class="stage-container slds-grid slds-nowrap slds-size--1-of-1" >

            <nav aura:id="nav-menu"
                 class="stage-left slds-size--2-of-12 slds-shrink-none slds-scrollable--y slds-p-around--small"
                 aria-label="Sub page">
                <div class="slds-nav-vertical__section">
                    <h2 id="entity-header" class="slds-nav-vertical__title slds-text-title_caps">Reports</h2>
                    <ul>
                        <li aura:id="nav-menu-li" onclick="{!c.onClickMenu}" data-action="gitHome"
                            class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="entity-header" aria-current="page">Recent</a></li>
                        <li aura:id="nav-menu-li" onclick="{!c.onClickMenu}" data-action="gitRepository"
                            class="slds-nav-vertical__item "><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="entity-header">Created by Me</a></li>
                        <li aura:id="nav-menu-li" onclick="{!c.onClickMenu}" data-action="codeCoverage"
                            class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="entity-header">Private Reports</a></li>
                        <li aura:id="nav-menu-li" onclick="{!c.onClickMenu}"
                            class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="entity-header">Public Reports</a></li>
                        <li aura:id="nav-menu-li" onclick="{!c.onClickMenu}"
                            class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="entity-header">All Reports</a></li>
                    </ul>
                </div>
                <div class="slds-nav-vertical__section">
                    <h2 id="folder-header" class="slds-nav-vertical__title slds-text-title_caps">Folders</h2>
                    <ul>
                        <li class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="folder-header">Created by Me</a></li>
                        <li class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="folder-header">Shared with Me</a></li>
                        <li class="slds-nav-vertical__item"><a href="javascript:void(0);" class="slds-nav-vertical__action" aria-describedby="folder-header">All Reports</a></li>
                    </ul>
                </div>
            </nav>

            {!v.body}

            <div aura:id="spinner" class="slds-spinner_container toggle">
                <div role="status" class="slds-spinner slds-spinner_large">
                    <span class="slds-assistive-text">Loading</span>
                    <div class="slds-spinner__dot-a"></div>
                    <div class="slds-spinner__dot-b"></div>
                </div>
            </div>

        </div>
    </div>
</aura:application>