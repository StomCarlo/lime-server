xquery version "3.0";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare variable $groupName external;

let $something := ()

return 
    xmldb:create-group($groupName)