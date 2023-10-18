page 6151289 "NPR POS Sales Document Setup"
{
    Extensible = false;
    Caption = 'POS Sales Document Setup';
    PageType = Card;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "NPR POS Sales Document Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(BackgroundPosting)
            {
                Caption = 'Background Posting';

                field("Post with Job Queue"; Rec."Post with Job Queue")
                {
                    ToolTip = 'Specifies if you use job queues to post sales documents from POS in the background.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action(ExtenstionFieldLocationSetup)
            {
                Caption = 'Ext.Field Loc.Setup';
                ToolTip = 'View or change document import data source extention field location filter setup.';
                ApplicationArea = NPRRetail;
                Image = ViewSourceDocumentLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    DataSourceExtFieldSetup: Record "NPR POS DS Exten. Field Setup";
                begin
                    DataSourceExtFieldSetup.FilterGroup(2);
                    DataSourceExtFieldSetup.SetRange("Extension Module", DataSourceExtFieldSetup."Extension Module"::DocImport);
                    DataSourceExtFieldSetup.FilterGroup(0);
                    Page.Run(Page::"NPR POS DS Exten. Field Setup", DataSourceExtFieldSetup);
                end;
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
