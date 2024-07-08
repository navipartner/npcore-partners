page 6150869 "NPR APIV1 PBIRetailCampLine"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'retailCampaignLine';
    EntitySetName = 'retailCampaignLines';
    Caption = 'PowerBI Retail Campaign Line';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR Retail Campaign Line";
    Extensible = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(id; Rec.SystemId) { }
                field("code"; Rec."Code") { }
                field(description; Rec.Description) { }
                field(lineNo; Rec."Line No.") { }
                field(type; Rec."Type") { }
                field(campaignCode; Rec."Campaign Code") { }

#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemModifiedAt; PowerBIUtils.GetSystemModifedAt(Rec.SystemModifiedAt)) { }
                field(lastModifiedDateTimeFilter; Rec.SystemModifiedAt) { }
                field(systemRowVersion; Rec.SystemRowVersion) { }
#ENDIF
            }
        }
    }
#IF NOT (BC17 or BC18 or BC19 or BC20)
    var
        PowerBIUtils: Codeunit "NPR PowerBI Utils";
#ENDIF
}