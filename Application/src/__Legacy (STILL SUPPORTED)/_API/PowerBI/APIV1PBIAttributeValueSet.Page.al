page 6150827 "NPR APIV1PBIAttributeValueSet"
{
    APIGroup = 'powerBI';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    PageType = API;
    EntityName = 'attributevalueset';
    EntitySetName = 'attributevaluesets';
    Caption = 'PowerBI Attribute Value Set';
    DataAccessIntent = ReadOnly;
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    Extensible = false;
    Editable = false;
    SourceTable = "NPR Attribute Value Set";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(attributeCode; Rec."Attribute Code")
                {
                    Caption = 'Attribute Code';
                }
                field(attributeSetID; Rec."Attribute Set ID")
                {
                    Caption = 'Attribute Set ID';
                }
                field(booleanValue; Rec."Boolean Value")
                {
                    Caption = 'Boolean Value';
                }
                field(datetimeValue; Rec."Datetime Value")
                {
                    Caption = 'Datetime Value';
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
                field(numericValue; Rec."Numeric Value")
                {
                    Caption = 'Numeric Value';
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
                field(textValue; Rec."Text Value")
                {
                    Caption = 'Text Value';
                }
            }
        }
    }
}
