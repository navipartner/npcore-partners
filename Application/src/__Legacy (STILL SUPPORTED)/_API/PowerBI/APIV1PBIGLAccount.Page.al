page 6059919 "NPR APIV1 PBIGLAccount"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'glAccount';
    EntitySetName = 'glAccounts';
    Caption = 'PowerBI G/L Account';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "G/L Account";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account Type', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }
                field(totaling; Rec.Totaling)
                {
                    Caption = 'Totaling', Locked = true;
                }
            }
        }
    }
}