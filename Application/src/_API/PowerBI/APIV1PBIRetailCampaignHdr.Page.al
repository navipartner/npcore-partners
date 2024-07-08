page 6150868 "NPR APIV1 PBIRetailCampaignHdr"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'retailCampaignHeader';
    EntitySetName = 'retailCampaignHeaders';
    Caption = 'PowerBI Retail Campaign Header';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    SourceTable = "NPR Retail Campaign Header";
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
                field(campaignNo; Rec."Campaign No.") { }
                field(distributionGroup; Rec."Distribution Group") { }
                field(magentoCategoryId; Rec."Magento Category Id") { }
                field(requestedDeliveryDate; Rec."Requested Delivery Date") { }

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