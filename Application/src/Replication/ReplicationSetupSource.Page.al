page 6059849 "NPR Replication Setup (Source)"
{
    ApplicationArea = NPRRetail;
    Caption = 'Replication Setup (Source Company)';
    ContextSensitiveHelpPage = 'retail/companies/howto/replicationhowto.html';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Replication Setup (Source)";
    UsageCategory = Administration;
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by SystemRowVersion';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Replication Counter"; Rec."Enable Replication Counter")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Enable Replication Counter';
                    Tooltip = 'Specifies if Replication Counter generation when records are Inserted, Modified or Renamed is enabled.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

}
