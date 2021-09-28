page 6014529 "NPR APIV1 - Variety"
{

    APIGroup = 'variety';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Variety';
    DelayedInsert = true;
    EntityName = 'variety';
    EntitySetName = 'varieties';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Variety";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(useinVariantDescription; Rec."Use in Variant Description")
                {
                    Caption = 'useinVariantDescription', Locked = true;
                }
                field(pretagInVariantDescription; Rec."Pre tag In Variant Description")
                {
                    Caption = 'pretagInVariantDescription', Locked = true;
                }
                field(useDescriptionfield; Rec."Use Description field")
                {
                    Caption = 'useDescriptionfield', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
