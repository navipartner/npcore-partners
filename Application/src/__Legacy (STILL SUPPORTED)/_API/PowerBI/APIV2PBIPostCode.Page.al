page 6151545 "NPR APIV2 PBIPostCode"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v2.0';
    PageType = API;
    EntityName = 'posCode';
    EntitySetName = 'posCodes';
    Caption = 'PowerBI Post Code';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "Post Code";
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
                field(city; Rec.City)
                {
                    Caption = 'City', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code', Locked = true;
                }
                field(county; Rec.County)
                {
                    Caption = 'County', Locked = true;
                }
                field(searchCity; Rec."Search City")
                {
                    Caption = 'Search City', Locked = true;
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt', Locked = true;
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy', Locked = true;
                }
                field(timeZone; Rec."Time Zone")
                {
                    Caption = 'Time Zone', Locked = true;
                }
                field(systemModifiedAt; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt))
                {
                    Caption = 'SystemModifiedAt', Locked = true;
                }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date Filter', Locked = true;
                }
#if not (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'System Row Version', Locked = true;
                }
#endif
            }
        }
    }
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
}