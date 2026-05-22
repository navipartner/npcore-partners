page 6150936 "NPR CMPartnerSetupList"
{
    Extensible = false;
    Caption = 'OTA Channel Manager Partner Setup';
    PageType = List;
    SourceTable = "NPR CMPartnerSetup";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(PartnerId; Rec.PartnerId)
                {
                    ToolTip = 'API identifier the channel partner uses when calling the channel manager API. Auto-generated on row creation. Use the Copy Partner Id action to share with the partner integration.';
                    ApplicationArea = NPRRetail;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Display name for the channel partner.';
                    ApplicationArea = NPRRetail;
                }

                field(Active; Rec.Active)
                {
                    ToolTip = 'If disabled, the partner cannot create or modify orders via the API.';
                    ApplicationArea = NPRRetail;
                }

                field(NPDesignerTemplateLabel; Rec.NPDesignerTemplateLabel)
                {
                    Caption = 'Wallet Design Layout';
                    ToolTip = 'NPDesigner template used to render the per-order wallet manifest for this partner. Leave blank to skip manifest generation.';
                    ApplicationArea = NPRRetail;
                }

                field(DocumentNoSeries; Rec.DocumentNoSeries)
                {
                    ToolTip = 'No. Series used to assign the Buy-from Order Reference for orders created by this partner. Leave blank to fall back to the auto-generated CM-YYMMDDHHMMSS-XXXX format.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CopyPartnerId)
            {
                Caption = 'Copy Partner Id';
                ToolTip = 'Show the partner''s API identifier in a dialog so you can copy it (Ctrl+C) and share with the partner integration.';
                Image = Copy;
                ApplicationArea = NPRRetail;
                Scope = Repeater;

                trigger OnAction()
                begin
                    Message(Format(Rec.PartnerId, 0, 4));
                end;
            }
            action(CreateJobQueueEntry)
            {
                Caption = 'Create Job Queue Entry';
                ToolTip = 'Create and start a Job Queue Entry that runs the OTA Channel Manager Job Queue Runner every minute. Required for async order processing — without it, orders submitted via the API stay in Submitted state and never advance. Safe to run repeatedly; if an entry already exists you''ll get an info message instead of a duplicate.';
                Image = JobJournal;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    JobQueueSetup: Codeunit "NPR CMJobQueueSetup";
                begin
                    JobQueueSetup.EnsureJobQueueEntry();
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if (IsNullGuid(Rec.PartnerId)) then
            Rec.PartnerId := CreateGuid();
    end;
}
