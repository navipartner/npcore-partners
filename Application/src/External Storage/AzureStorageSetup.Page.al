page 6184860 "NPR Azure Storage Setup"
{
    Caption = 'Azure Storage Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR Azure Storage API Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name"; "Account Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Azure Account Name field';
                }
                field("Account Description"; "Account Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Azure Account Description field';
                }
                field(AccessKey; AccessKey)
                {
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                    ApplicationArea = All;
                    ToolTip = 'Miliseconds';
                }
                field("Storage On Server"; "Storage On Server")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server files location field';
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

