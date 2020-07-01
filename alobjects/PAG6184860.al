page 6184860 "Azure Storage Setup"
{
    // NPR5.54/ALST/20200212 CASE 383718 Object created

    Caption = 'Azure Storage Setup';
    PageType = List;
    SourceTable = "Azure Storage API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name"; "Account Name")
                {
                }
                field("Account Description"; "Account Description")
                {
                }
                field(AccessKey; AccessKey)
                {
                    Caption = 'Shared Access Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Storage account -> Settings section -> Access keys -> key1 or key2';

                    trigger OnValidate()
                    begin
                        HandleAccessKey(AccessKey);
                    end;
                }
                field(AdminKey; AdminKey)
                {
                    Caption = 'Search App Admin Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Search Service -> Settings section -> Keys -> "Primary admin key" or "Secondary admin key"';

                    trigger OnValidate()
                    begin
                        HandleAdminKey(AdminKey);
                    end;
                }
                field(Timeout; Timeout)
                {
                    ToolTip = 'Miliseconds';
                }
                field("Storage On Server"; "Storage On Server")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if not IsNullGuid("Access Key") then begin
            IsolatedStorage.Get("Access Key", DataScope::Company, AccessKey);
        end;

        if not IsNullGuid("Admin Key") then begin
            IsolatedStorage.Get("Admin Key", DataScope::Company, AdminKey);
        end;
    end;

    var
        AccessKey: Text;
        AdminKey: Text;
}

