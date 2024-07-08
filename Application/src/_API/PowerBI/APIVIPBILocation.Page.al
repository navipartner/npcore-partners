page 6059986 "NPR APIV1 PBILocation"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'location';
    EntitySetName = 'locations';
    Caption = 'Power BI Location';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    SourceTable = Location;
    Extensible = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(nprStoreGroupCode; Rec."NPR Store Group Code")
                {
                    Caption = 'Store Group Code';
                }
            }
        }
    }
}
