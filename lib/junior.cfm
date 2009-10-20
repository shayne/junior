<cfparam name="caller.params" default="#structnew()#" />

<cfset run() />

<cffunction name="run">
	<cfset var tag_name = rematch("CF_[^,]+", getbasetaglist())[1] />
	<cfset tag_name = right(tag_name, len(tag_name)-3) />
	<cfset tag_name = iif(refindnocase("get|put|post|delete", tag_name), "'method'", "tag_name") />
	<cfset request.url = iif(len(cgi.path_info), "cgi.path_info", "'/'") />
	<cfset request.method = iif(structkeyexists(form, "_method"), "form._method", "cgi.request_method") />
	<cfinvoke method="#tag_name#_tag" />
</cffunction>

<cffunction name="method_tag">
	<cfif find(":", attributes.url)>
		<cfset url_vars = rematch(":[a-z]+", attributes.url) />
		<cfset url_vals = refind(rereplacenocase(attributes.url, ":[a-z]+", "([^/]+)", "all"), request.url, 1, true) />
		<cfif NOT url_vals.len[1]>
			<cfexit />
		</cfif>
		<cfloop index="i" from="2" to="#arraylen(url_vals.len)#">
			<cfset caller.params[right(url_vars[i-1], len(url_vars[i-1])-1)] = mid(request.url, url_vals.pos[i], url_vals.len[i]) />
		</cfloop>
	<cfelseif NOT attributes.url EQ iif(len(request.url), "request.url", "'/'")>
		<cfexit />
	</cfif>
</cffunction>

<cffunction name="cfm_tag">
	<cfcontent reset="true" />
	<cfset structappend(variables, caller, true) />
	<cfif fileexists(expandpath("/views/layout.cfm"))>
		<cfinclude template="/views/layout.cfm" />
	<cfelse>
		<cfinclude template="/views/#attributes.view#.cfm" />
	</cfif>
</cffunction>

<cffunction name="yield">
	<cfinclude template="/views/#attributes.view#.cfm" />
</cffunction>