page 6184860 "Azure Storage Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Setup';
    PageType = List;
    Permissions = TableData "Service Password"=rimd;
    SourceTable = "Azure Storage API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name";"Account Name")
                {
                }
                field("Account Description";"Account Description")
                {
                }
                field(AccessKey;AccessKey)
                {
                    Caption = 'Shared Access Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Storage account -> Settings section -> Access keys -> key1 or key2';

                    trigger OnValidate()
                    begin
                        HandleAccessKey(AccessKey);
                    end;
                }
                field(AdminKey;AdminKey)
                {
                    Caption = 'Search App Admin Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Search Service -> Settings section -> Keys -> "Primary admin key" or "Secondary admin key"';

                    trigger OnValidate()
                    begin
                        HandleAdminKey(AdminKey);
                    end;
                }
                field(Timeout;Timeout)
                {
                    ToolTip = 'Miliseconds';
                }
                field("Storage On Server";"Storage On Server")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    var
        ServicePassword: Record "Service Password";
    begin
        if not IsNullGuid("Access Key") then begin
          ServicePassword.SetRange(Key, "Access Key");
          ServicePassword.FindFirst;
          AccessKey := ServicePassword.GetPassword();
        end;

        if not IsNullGuid("Admin Key") then begin
          ServicePassword.SetRange(Key, "Admin Key");
          ServicePassword.FindFirst;
          AdminKey := ServicePassword.GetPassword();
        end;
    end;

    var
        AccessKey: Text;
        AdminKey: Text;
}

