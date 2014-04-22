require_relative '../models/user'
require_relative '../models/orgrole'
require_relative '../models/org'
class App
  

 
 def process_role(user_id, organization_id)
   # presuming we already have the user_id, next get the user's role in the organization
   # There is no presumption that there is a role specified for each user for every organzition - leaf levels may not have roles defined
   
   # if a leaf doesn't have a role for a user, use the user's role in the parent.
   
   #get the parent org to the specified org - necessary to check inheritance...
   # root not taken into account since the parent org falls below root in the example
   org_parent_id=Org.get_parent_id(organization_id)
   #org_parent_id=org.
   
   
   current_role = OrgRole.get_current_role(user_id, organization_id)
   parent_role = OrgRole.get_parent_role(org_parent_id,user_id)
   
   #if a role is specified on current_role, use that
   if !(current_role.nil?)
     #current_role
     use_role =current_role
   else
     #parent_role
     
     use_role = parent_role.to_s
     
   end
   
   #else, check parent_role
   
  
   if use_role =='Admin'
     #render partial, html, etc
      admin_role
   end
   
   if use_role=='User'
    #render partial, html, etc
      user_role
   end
   
   if use_role=='Denied' || use_role.nil?
     #if no parent role is defined, deny access
    #render partial, html, etc
    denied_role
    
   end

   
 end
 
 def denied_role
 end

 def admin_role
 end
 
 def user_role
 end
 
 
end
