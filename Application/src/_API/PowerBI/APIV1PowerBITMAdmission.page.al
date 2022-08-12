page 6059965 NPRPBITMAdmission
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmAdmission';
    EntitySetName = 'tmAdmissions';
    Caption = 'PowerBI TM Admission';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Admission";
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
                field(admissionCode; Rec."Admission Code")
                {
                    Caption = 'Admission Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(type; Rec."Type")
                {
                    Caption = 'Type', Locked = true;
                }
            }
        }
    }
}