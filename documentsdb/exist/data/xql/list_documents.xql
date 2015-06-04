
(: Declare the namespace for the ajax functions in wawe :)
declare namespace ajax = "http://www.wawe.com/ajax";

(: Declare the namespace for the advanced functions :)
declare namespace functx = "http://www.functx.com";

(: Declare the namespace for functions of the exist xml db :)
declare namespace xdb="http://exist-db.org/xquery/xmldb";

(: Get the username and the password passed by the server :)
declare variable $userName external;
declare variable $password external;
declare variable $requestedCollection external;
declare variable $encodedUserName := replace($userName, '@', '.');

(: The substring after last function :)
declare function functx:substring-after-last 
		($arg as xs:string?,
  		 $delim as xs:string) 
		as xs:string 
		{
   			replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 		};

(: The substring before last function :)
declare function functx:substring-before-last 
  		($arg as xs:string?,
    	 $delim as xs:string)  
		as xs:string 
		{
   			if (matches($arg, functx:escape-for-regex($delim)))
   				then replace($arg,
     						 concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            				 '$1')
   			else ''
 		};

declare function functx:escape-for-regex 
  		($arg as xs:string?)  
		as xs:string 
		{
   			replace($arg,
           			'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 		};

(: Calls the function that lists the collections getting the collection name external declared variable:)
declare variable $collection := replace($requestedCollection, ' ', '%20');
declare variable $relativePath := functx:substring-after-last($collection, $encodedUserName);



(: Login the user :)
declare variable $userLogin := xmldb:login('/db', $userName, $password);

(: This function return an XML containig all the collections and the files in the given collection :)
declare function ajax:display-collection($collection as xs:string, $username as xs:string) as 
element()* {
    let $encodedUsername := replace($userName, '@', '.')
(:    let $userPath := substring-after($collection, concat($encodedUsername, '/')):)
    return ( 
        
        
		(: Iterate all the collection in the given collection :)
        for $child in xdb:get-child-collections($collection) order by $child 
       
        (: Returns an XML fragment describing the collection :)
        return
            (: Hide the autosave temporary folder :)
            if (contains($child, 'autosave')) then
                ()
            else
                let $childName := replace($child, '([a-z]{3})((%40)|(\.))','$1@')
                return
                <node>
    				<id>{concat($collection, '/', replace($child,'%40','@'))}</id> 
                    (: The language is in the uri as lang@ with @ replaced by a dot :)
                    <text>{
                        $childName
                    }</text>
                    <path>{concat($relativePath, '/', replace($child,'%40','@'))}</path> 
    				<cls>folder</cls>
    				<leaf></leaf>
                </node>,

        (: Iterate all the files in the given collection :)
        for $child in xdb:get-child-resources($collection) order by $child 
        (: Returns an XML fragment describing the file :)
        return
            (: Hide the autosave temporary folder :)
            if (contains($child, '.metadata')) then
                ()
            else
                <node> 
                    <id>{concat($collection, '/', replace($child,'%40','@'))}</id> 
                    <text>{replace($child,'%40','@')}</text> 
                    <type>resource</type> 
                    <path>{concat($relativePath, '/', replace($child,'%40','@'))}</path>
    				<cls>file</cls>
    				<leaf>1</leaf> 
                    <mime>{xdb:get-mime-type(xs:anyURI(concat($collection, '/', $child)))}</mime> 
                    <size>{fn:ceiling(xdb:size($collection, $child) div 1024)}</size> 
                </node> 
     ) 
}; 

(: Temporary :)
let $something := ()

return 
	<ajax-response> 
    { 
        ajax:display-collection($collection, $userName) 
    } 
    </ajax-response>