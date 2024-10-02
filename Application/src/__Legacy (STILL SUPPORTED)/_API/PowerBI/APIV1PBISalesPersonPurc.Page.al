page 6059938 "NPR APIV1 PBISalesPersonPurc"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'salesPerson';
    EntitySetName = 'salesPersons';
    Caption = 'PowerBI SalesPerson/Purchaser';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Salesperson/Purchaser";
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
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(jobTitle; Rec."Job Title")
                {
                    Caption = 'Job Title', Locked = true;
                }
            }
        }
    }
}