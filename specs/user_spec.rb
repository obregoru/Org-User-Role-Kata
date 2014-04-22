require_relative '../app/controllers/app'
require_relative '../app/models/user'
require_relative '../app/models/orgrole'
require_relative '../app/models/org'

describe App do
  before(:each) do
    @user = User.new
    @user.id=1
    @user.username="Tron"
    
    @org_id=1
    
    #admin over org1
    @org_role = OrgRole.new
    @org_role.org_id=2
    @org_role.user_id=1
    @org_role.role='Admin'
    #admin over child org 1
    @org_role_1 = OrgRole.new
    @org_role_1.org_id=3
    @org_role_1.user_id=1
    @org_role_1.role='Admin'
    #denied child org 2
    @org_role_2 = OrgRole.new
    @org_role_2.org_id=4
    @org_role_2.user_id=1
    @org_role_2.role='Denied'
  
    #user child org 3
    @org_role_3 = OrgRole.new
    @org_role_3.org_id=5
    @org_role_3.user_id=1
    @org_role_3.role='User'
  
    #root org
    @root_org=Org.new
    @root_org.id=1 #root
    @root_org.description='root'
    @root_org.parent_id=1  
    
    #org 1
    @org=Org.new
    @org.id=2 #org 1
    @org.description='Org 1'
    @org.parent_id=0  
    
    #child org 1
    @child_org_1=Org.new
    @child_org_1.id=3 #child org 1
    @child_org_1.description='Child Org 1 (admin)'
    @child_org_1.parent_id=2 
    
    #child org 2
    @child_org_2 = Org.new
    @child_org_2.id=4 #child org 2
    @child_org_2.description='Child org 2 (denied)'
    @child_org_2.parent_id=2
    
    #child org 3
    @child_org_3 = Org.new
    @child_org_3.id=5 #child org 2
    @child_org_3.description='Child org 3 (user)'
    @child_org_3.parent_id=2
    
    
    #child org 4
    @child_org_3 = Org.new
    @child_org_3.id=6 #child org 2
    @child_org_3.description='Child org 4 (inherited)'
    @child_org_3.parent_id=2
    
    Org.stub(:get_parent_id).and_return(:organization_id=>@child_org_2.parent_id)
   
  end
  
  #tests check for each organization
  
  #presumes user authenticated in prior tests - picking up at authorization point
  
  #test designed to prove out that the various roles, and inheritiance, work for each org
  
  it 'should receive id of parent org' do
     OrgRole.stub(:get_current_role).and_return(@org_role_2.role)
     OrgRole.stub(:get_parent_role).and_return(@org_role_2.role)
     usr= App.new
     usr.stub(:get_parent_role).and_return(@org_role_2.role)
     usr.stub(:get_current_role).and_return(@org_role_2.role)
     usr.process_role(@user.id, :organization_id=>@child_org_2.id)
     expect(Org).to have_received(:get_parent_id).with({:organization_id=>@child_org_2.id})
  end
  
  
  it 'should be in the admin role for the parent org ' do
     OrgRole.stub(:get_current_role).and_return(@org_role.role)
     OrgRole.stub(:get_parent_role).and_return(@org_role.role)
     usr= App.new
     usr.stub(:admin_role)
     usr.stub(:get_parent_role).and_return(@org_role.role)
     usr.stub(:get_current_role).and_return(@org_role.role)
     usr.process_role(@user.id, :organization_id=>@org_role.org_id)
     expect(usr).to have_received(:admin_role)
     
  end
  
  it 'should NOT be in the denied role for the parent org ' do
     OrgRole.stub(:get_current_role).and_return(@org_role.role)
     OrgRole.stub(:get_parent_role).and_return(@org_role.role)
     usr= App.new
     usr.stub(:denied_role)
     usr.stub(:get_parent_role).and_return(@org_role.role)
     usr.stub(:get_current_role).and_return(@org_role.role)
     usr.process_role(@user.id, :organization_id=>@org_role.org_id)
     expect(usr).not_to have_received(:denied_role)
     
  end
  
  it 'should NOT be in the users role for the parent org ' do
     OrgRole.stub(:get_current_role).and_return(@org_role.role)
     OrgRole.stub(:get_parent_role).and_return(@org_role.role)
     usr= App.new
     usr.stub(:user_role)
     usr.stub(:get_parent_role).and_return(@org_role.role)
     usr.stub(:get_current_role).and_return(@org_role.role)
     usr.process_role(@user.id, :organization_id=>@org_role.org_id)
     expect(usr).not_to have_received(:user_role)
     
  end
  
  # further testing of children and inheritiance - could expand to
  # not_to have_received of roles but I believe this test
  # illustrates the point of the exercise
  
  it 'should be in admin role for child org 1' do
    OrgRole.stub(:get_current_role).and_return(@org_role_1.role)
    OrgRole.stub(:get_parent_role).and_return(@org_role_1.role)
    
    usr= App.new
    usr.stub(:admin_role)
    usr.process_role(@user.id, :organization_id=>@child_org_1.id)
    expect(usr).to have_received(:admin_role)
     
  end
  
  it 'should be in the denied role for child org 2' do
    OrgRole.stub(:get_current_role).and_return(@org_role_2.role)
    OrgRole.stub(:get_parent_role).and_return(@org_role_2.role)
    usr= App.new
    usr.stub(:denied_role)
    usr.process_role(@user.id, :organization_id=>@child_org_2.id)
    expect(usr).to have_received(:denied_role)
     
  end
  
  
  it 'should be in the user role for child org 3' do
    OrgRole.stub(:get_current_role).and_return(@org_role_3.role)
    OrgRole.stub(:get_parent_role).and_return(@org_role_3.role)
    usr= App.new
    usr.stub(:user_role)
    usr.process_role(@user.id, :organization_id=>@org_role_3.org_id)
    expect(usr).to have_received(:user_role)
     
  end
  
  it 'should inherit the user role for child org 4' do
    OrgRole.stub(:get_current_role).and_return(nil)
    OrgRole.stub(:get_parent_role).and_return(@org_role.role)
    usr= App.new
    usr.stub(:admin_role)
    usr.process_role(@user.id, :organization_id=>@child_org_3.id)
    expect(usr).to have_received(:admin_role)
  end
  
end
