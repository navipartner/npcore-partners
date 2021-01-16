page 6059932 "NPR Doc. Exchange Activities"
{
    // NPR5.25/BR /20160804 CASE 244303 Object Created
    // NPR5.29/BR /20161124 CASE 259274 Updated for NAV 2017: Changed Drill-down to Sales Invoice List
    // NPR5.40/THRO/20180316 CASE 308392 Named group Incoming Documents "Incoming Documents Group" for AL conversion
    // NPR5.41/TS  /20180105 CASE 300893 Removed s in Incoming Document

    Caption = 'Doc. Exchange Activities';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Doc. Exch. Cue";

    layout
    {
        area(content)
        {
            group("Incoming Documents Group")
            {
                Caption = 'Incoming Document';
                cuegroup(Control6150625)
                {
                    ShowCaption = false;

                    actions
                    {
                        action("Import Files Now")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Executes the Import Files Now action';

                            trigger OnAction()
                            var
                                DocExchFileMgt: Codeunit "NPR Doc. Exch. File Mgt.";
                            begin
                                Clear(DocExchFileMgt);
                                DocExchFileMgt.Run;
                                CurrPage.Update
                            end;
                        }
                    }
                }
                cuegroup(Control4)
                {
                    ShowCaption = false;
                    field("Incoming Documents"; "Incoming Documents")
                    {
                        ApplicationArea = All;
                        Caption = 'Total';
                        ToolTip = 'Specifies the value of the Total field';
                    }
                    field("Incoming Documents Created"; "Incoming Documents Created")
                    {
                        ApplicationArea = All;
                        Caption = 'Created';
                        ToolTip = 'Specifies the value of the Created field';
                    }
                }
                cuegroup("In Process")
                {
                    Caption = 'In Process';
                    field("Incoming Documents New"; "Incoming Documents New")
                    {
                        ApplicationArea = All;
                        Caption = 'New';
                        ToolTip = 'Specifies the value of the New field';
                    }
                    field("Incoming Documents Released"; "Incoming Documents Released")
                    {
                        ApplicationArea = All;
                        Caption = 'Released';
                        ToolTip = 'Specifies the value of the Released field';
                    }
                    field("Incoming Documents Pending Ap."; "Incoming Documents Pending Ap.")
                    {
                        ApplicationArea = All;
                        Caption = 'Pending Approval';
                        ToolTip = 'Specifies the value of the Pending Approval field';
                    }
                }
                cuegroup(Attention)
                {
                    Caption = 'Attention';
                    field("Incoming Documents Failed"; "Incoming Documents Failed")
                    {
                        ApplicationArea = All;
                        Caption = 'Failed';
                        Style = Unfavorable;
                        StyleExpr = HasFailedIncoming;
                        ToolTip = 'Specifies the value of the Failed field';
                    }
                    field("Incoming Documents Rejected"; "Incoming Documents Rejected")
                    {
                        ApplicationArea = All;
                        Caption = 'Rejected';
                        Style = Unfavorable;
                        StyleExpr = HasRejectedIncoming;
                        ToolTip = 'Specifies the value of the Rejected field';
                    }
                }
            }
            group("Invoices and Approvals")
            {
                Caption = 'Invoices and Approvals';
                cuegroup(Control6150618)
                {
                    ShowCaption = false;
                    field("Ongoing Purchase Invoices"; "Ongoing Purchase Invoices")
                    {
                        ApplicationArea = All;
                        Caption = 'Purchase Invoices';
                        ToolTip = 'Specifies the value of the Purchase Invoices field';
                    }
                    field("Ongoing Sales Invoices"; "Ongoing Sales Invoices")
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Invoices';
                        DrillDownPageID = "Sales Invoice List";
                        ToolTip = 'Specifies the value of the Sales Invoices field';
                    }
                    field("Requests to Approve"; "Requests to Approve")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Requests to Approve field';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        HasFailedIncoming := "Incoming Documents Failed" > 0;
        HasRejectedIncoming := "Incoming Documents Rejected" > 0;
    end;

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;

        SetRange("User ID Filter", UserId);

        HasCamera := CameraProvider.IsAvailable;
        if HasCamera then
            CameraProvider := CameraProvider.Create;
    end;

    var
        [RunOnClient]
        [WithEvents]
        CameraProvider: DotNet NPRNetCameraProvider;
        HasCamera: Boolean;
        HasFailedIncoming: Boolean;
        HasRejectedIncoming: Boolean;

    trigger CameraProvider::PictureAvailable(PictureName: Text; PictureFilePath: Text)
    var
        IncomingDocument: Record "Incoming Document";
    begin
        IncomingDocument.CreateIncomingDocument(PictureName, '');
        IncomingDocument.AddAttachmentFromServerFile(PictureName, PictureFilePath);

        CurrPage.Update;
    end;
}

