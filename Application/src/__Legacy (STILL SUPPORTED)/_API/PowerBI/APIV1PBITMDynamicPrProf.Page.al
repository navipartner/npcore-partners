page 6150785 "NPR APIV1 PBITMDynamicPrProf"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'tmDynamicPriceProfile';
    EntitySetName = 'tmDynamicPriceProfile';
    Caption = 'PowerBI TM Dynamic Price Profile ';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR TM Dynamic Price Profile";
    Extensible = false;
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(profileCode; Rec.ProfileCode)
                {
                    Caption = 'Profile Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
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
}