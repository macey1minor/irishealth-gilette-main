/// Created using the page template: Column 2
Class IIBAENSEMBLE.Zen.ToolkitTemplate Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION = "IIBAENSEMBLE.Zen.Toolkit";

/// Displayed name of this page.
Parameter PAGENAME = "Toolkit Template";

/// Domain used for localization.
Parameter DOMAIN;

Property Namespace As %String;

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">
/* style for title bar */
#title {
	background: White;
	color: black;
	font-family: Verdana;
	font-size: 1.5em;
	font-weight: bold;
	padding: 5px;
	width: 100%;
	text-align: center;
}
#date {
	background: White;
	color: #F2D230;
	font-family: Verdana;
	padding-right: 20px;
	width: 222px;
	text-align: right;
}
#menubar {
	background: #F2D230;
	color: black;
	font-family: Verdana;
	font-size: 1.5em;
	font-weight: bold;
	padding: 5px;
	border-bottom: 1px solid black;
	text-align: left;
}
/* group on left-hand side */
#groupLeft {
	border-right: 1px solid black;
	background: #F2E394;
	height: 600px;
	width: 155px;
	overflow: auto;
}
/* group on right-hand side */
#groupRight {
	border-right: 1px solid black;
	background: #F2F2F2;
	height: 600px;
	overflow: auto;
}
table.menuTable {
	font-size: 0.8em; 
	margin-left: 0px;
	margin-right: 0px;
	margin-top: 0px;
	margin-bottom: 5px;
	padding: 5px;
	/*border-top: 1px gray solid;
	border-bottom: 1px gray solid;*/
	width: 100%;
	background: #F2E394;
	font-family: Arial, Helvetica, sans-serif;
	border: none;
	/*border-top: 1px solid lightgray;
	border-left: 1px solid lightgray;
	border-right: 2px solid gray;
	border-bottom: 2px solid gray;*/
}
/* Default style overrides*/
/* Override default menu item style */
a.menuItem {
	/*background: #356B8D;*/
	background: #3F5F70;
	text-decoration: none; 
	font-family: Arial, Helvetica, sans-serif;
	font-size:12px;
	font-weight:bold;
	color: #E0E0E0;
	padding: 3px;
	padding-top: 1px;
	padding-left: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	width: 100%;
	border: 1px solid lightgray;
	border-top: 1px solid lightgray;
	border-left: 1px solid lightgray;
	border-right: 2px solid gray;
	border-bottom: 2px solid gray;
}

/* @doc="Mouse over menu item." */
a.menuItem:hover {
	background-image: url(portal/button_hover.png);
	background-repeat: repeat-x;
	text-decoration: none; 
	font-family: Arial, Helvetica, sans-serif;
	font-size:12px;
	font-weight:bold;
	color: #E0E0E0;
	padding: 3px;
	padding-top: 1px;
	padding-left: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	border: 1px solid lightgray;
	border-top: 1px solid lightgray;
	border-left: 1px solid lightgray;
	border-right: 2px solid gray;
	border-bottom: 2px solid gray;

}

 a.menuItem:active {
		color: #FF0000;	
}

/* @doc="Disabled menu item." */
a.menuItemDisabled {
	background: #606060;
	font-size:12px;
	font-weight:bold;
	color: #FFFFFF;
	text-decoration: none; 
	font-family: Arial, Helvetica, sans-serif;
	padding: 2px 5px 5px 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	border: 1px solid lightgray;
	border-top: 1px solid lightgray;
	border-left: 1px solid lightgray;
	border-right: 2px solid gray;
	border-bottom: 2px solid gray;
}
<link rel="stylesheet" type="text/css" href="/csp/sys/intersystems.css"/>
</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="">
<!-- <html OnDrawContent="DrawTitle"/> -->
<hgroup id="hgrouptop">
<vgroup align="left">
<image align="left" alt="Nuvodia" id="logo" src="http://www.inlandimaging.com/Nuvodia_logo_emailSig.jpg"></image>
</vgroup>
<vgroup align="center" width="100%">
<html id="title" OnDrawContent="DrawTitle"/>
</vgroup>
<vgroup align="right">
<html id="date" OnDrawContent="DrawDate"/>
</vgroup>
</hgroup>
<html id="menubar"></html>
<hgroup id="hgroup" width="100%">
<vgroup id="groupLeft">
<!-- put contents of left column here -->
<pane paneName="menuPane" width="100%">
<menu id="Toolkit" layout="vertical" help="Top" width="100%" >
<menuItem caption="Lookup Table Audit" imageWidth="1px" link="IIBAENSEMBLE.Zen.TableAuditList.cls" target="_top"  />
<menuItem caption="xRef Audit" imageWidth="1px" link="IIBAENSEMBLE.Zen.xRefAuditList.cls" target="_top" />
<menuItem caption="xRefAttr Audit" imageWidth="1px" link="IIBAENSEMBLE.Zen.xRefAttrAuditList.cls" target="_top" />
<menuItem caption="Alert Admin" imageWidth="1px" link="IIBAENSEMBLE.Zen.AlertAdminTable.cls" target="_top"/>
<menuItem caption="Back to Toolkit" imageWidth="1px"  link="IIBASupport.csp" target="_top"  />
<menuItem caption="Manage" imageWidth="1px"  link="%25CSP.Portal.Home.zen" target="_top"  />
</menu>
</pane>
</vgroup>
<vgroup id="groupRight">
<!-- put contents of right column here -->
<pane paneName="tablePane"/>
<spacer height="20"/>
<pane paneName="detailPane"/>
</vgroup>
</hgroup>
</page>
}

/// This method is called when this page is resized.
/// In response to a resize, we use JavaScript to dynamically
/// resize the 2 main groups on this page.
/// You can modify this method to meet your needs.
ClientMethod onlayoutHandler(load) [ Language = javascript ]
{
	// find enclosing div for the title (if present) and get its height
	var title = zenPage.getComponentById('title');
	var divTitle = title ? title.getEnclosingDiv() : null;
	var hgtTitle = divTitle ? parseInt(divTitle.offsetHeight) : 0;
	// find the enclosing divs for the 2 groups
	var groupLeft = zenPage.getComponentById('groupLeft');
	var groupRight = zenPage.getComponentById('groupRight');
	var divgroupLeft = groupLeft ? groupLeft.getEnclosingDiv() : null;
	var divgroupRight = groupRight ? groupRight.getEnclosingDiv() : null;
	// find height of window
	var winHeight = zenGetWindowHeight();
	var winWidth = zenGetWindowWidth();
	// adjust the size of groups
	var widLeft = divgroupLeft ? parseInt(divgroupLeft.offsetWidth) : 0;
	var widRight = winWidth - widLeft - 10;
	var hgt = winHeight - hgtTitle - 30;
	if (divgroupLeft) {
		divgroupLeft.style.height = hgt + 'px';
	}
	if (divgroupRight) {
		divgroupRight.style.height = hgt + 'px';
		divgroupRight.style.width = widRight + 'px';
	}
}

Method DrawTitle(pSeed As %String) As %Status
{
	&html<<div>Toolkit - #($ZCVT(..#PAGENAME,"O","HTML"))#</div>>
	set ..Namespace = $ZNSPACE
	quit $$$OK
}

Method DrawDate(pSeed As %String) As %Status
{
	&html<<div>#($ZCVT(($ZDATETIME($HOROLOG,3,2)),"O","HTML"))#</div>>
	quit $$$OK
}

}
