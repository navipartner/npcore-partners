page 6150829 "NPR APIV1AttributeKey"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'attributekey';
    EntitySetName = 'attributekeys';
    Caption = 'PowerBI Attribute Key';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;
    Editable = false;
    SourceTable = "NPR Attribute Key";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(attributeSetID; Rec."Attribute Set ID")
                {
                    Caption = 'Attribute Set ID';
                }
                field(mdrCode2PK; Rec."MDR Code 2 PK")
                {
                    Caption = 'MDR Code 2 PK';
                }
                field(mdrCodePK; Rec."MDR Code PK")
                {
                    Caption = 'MDR Code PK';
                }
                field(mdrLine2PK; Rec."MDR Line 2 PK")
                {
                    Caption = 'MDR Line 2 PK';
                }
                field(mdrLinePK; Rec."MDR Line PK")
                {
                    Caption = 'MDR Line PK';
                }
                field(mdrOptionPK; Rec."MDR Option PK")
                {
                    Caption = 'MDR Option PK';
                }
                field(systemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'SystemCreatedAt';
                }
                field(systemCreatedBy; Rec.SystemCreatedBy)
                {
                    Caption = 'SystemCreatedBy';
                }
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }
                field(systemModifiedBy; Rec.SystemModifiedBy)
                {
                    Caption = 'SystemModifiedBy';
                }
                field(tableID; Rec."Table ID")
                {
                    Caption = 'Table ID';
                }
            }
        }
    }
}
