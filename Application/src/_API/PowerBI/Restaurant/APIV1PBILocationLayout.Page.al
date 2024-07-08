page 6059992 "NPR APIV1 PBILocation Layout"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'locationLayout';
    EntitySetName = 'locationLayouts';
    Caption = 'PowerBI Location Layout';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR NPRE Location Layout";
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
                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type', Locked = true;
                }
                field(seatingLocation; Rec."Seating Location")
                {
                    Caption = 'Seating Location', Locked = true;
                }
                field(seatingNo; Rec."Seating No.")
                {
                    Caption = 'Seating No.', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
            }
        }
    }
}