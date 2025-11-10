page 6151015 "NPR NpRv Vouchers"
{
    Caption = 'Retail Vouchers';
    ContextSensitiveHelpPage = 'docs/retail/vouchers/explanation/voucher_types/';
    CardPageID = "NPR NpRv Voucher Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies unique number of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Type"; Rec."Voucher Type")
                {
                    ToolTip = 'Specifies the voucher type. Credit and gift vouchers are default, but additional ones can be defined as well.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Date"; Rec."Issue Date")
                {
                    ToolTip = 'Specifies the issue date of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field(Open; Rec.Open)
                {
                    ToolTip = 'Specifies if the voucher is open or not.';
                    ApplicationArea = NPRRetail;
                }
                field("Initial Amount"; Rec."Initial Amount")
                {
                    Visible = true;
                    ToolTip = 'Specifies the initial amount of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the amount of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Reserved Amount"; Rec."Reserved Amount")
                {
                    Visible = ReservedAmountVisible;
                    ToolTip = 'Specifies the reserved amount of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the starting date of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ToolTip = 'Specifies the ending date of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ToolTip = 'Specifies the reference number of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Register No."; Rec."Issue Register No.")
                {
                    ToolTip = 'Specifies the issue register number of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Document Type"; Rec."Issue Document Type")
                {
                    ToolTip = 'Specifies the issue document type of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Document No."; Rec."Issue Document No.")
                {
                    ToolTip = 'Specifies the issue document number of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue External Document No."; Rec."Issue External Document No.")
                {
                    ToolTip = 'Specifies the issue external document number of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue User ID"; Rec."Issue User ID")
                {
                    ToolTip = 'Specifies the issue user ID of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Issue Partner Code"; Rec."Issue Partner Code")
                {
                    ToolTip = 'Specifies the issue partner code of the voucher.';
                    ApplicationArea = NPRRetail;
                }
                field("Partner Clearing"; Rec."Partner Clearing")
                {
                    ToolTip = 'Specifies if the partner clearing exists or not.';
                    ApplicationArea = NPRRetail;
                }
                field("No. Send"; Rec."No. Send")
                {
                    Visible = false;
                    ToolTip = 'Specifies how many times a voucher has been sent via email, SMS or printer.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Arch. Vouchers")
                {
                    Caption = 'Archive Vouchers';
                    Image = Post;
                    ToolTip = 'Archive the selected voucher/s.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Voucher: Record "NPR NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                        ConfirmManagement: Codeunit "Confirm Management";
                        ArchiveVoucherQst: Label 'Archive %1 selected vouchers manually?', Comment = '%1 = Number of vouchers';
                    begin
                        CurrPage.SetSelectionFilter(Voucher);
                        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ArchiveVoucherQst, Voucher.Count), false) then
                            exit;

                        NpRvVoucherMgt.ArchiveVouchers(Voucher);
                    end;
                }
                action("Show Expired Vouchers")
                {
                    Caption = 'Show Expired Vouchers';
                    Image = "Filter";
                    ToolTip = 'Displays the expired vouchers.';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Rec.SetFilter("Ending Date", '<%1', CurrentDateTime);
                    end;
                }
            }
        }
        area(navigation)
        {
            action("Voucher Entries")
            {
                Caption = 'Voucher Entries';
                Image = Entries;
                RunObject = Page "NPR NpRv Voucher Entries";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Ctrl+F7';
                ToolTip = 'Displays the voucher entries of the selected record.';
                ApplicationArea = NPRRetail;
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ToolTip = 'Displays the sending log of the selected record.';
                ApplicationArea = NPRRetail;
            }
            action("Show Archived Vouchers")
            {
                Caption = 'Show Archived Vouchers';
                Image = PostedPutAway;
                RunObject = Page "NPR NpRv Arch. Vouchers";
                ToolTip = 'Displays the archived vouchers.';
                ApplicationArea = NPRRetail;
            }
            action(ViewOnline)
            {
                Caption = 'View Online';
                Image = SendAsPDF;
                ToolTip = 'Opens the voucher in a web browser.';
                ApplicationArea = NPRRetail;
                Scope = Repeater;

                trigger OnAction()
                var
                    DesignerFacade: Codeunit "NPR NPDesignerManifestFacade";
                    VoucherType: Record "NPR NpRv Voucher Type";
                    AddAssetFailed: Label 'Unable to add the voucher to the manifest.';
                    CreateUrlFailed: Label 'Unable to get the manifest URL.';
                    ManifestUrl: Text[250];
                    ManifestId: Guid;
                begin
                    ClearLastError();
                    VoucherType.Get(Rec."Voucher Type");
                    VoucherType.TestField(PDFDesignerTemplateId);
                    ManifestId := DesignerFacade.CreateManifest();
                    if (not DesignerFacade.AddAssetToManifest(ManifestId, DATABASE::"NPR NpRv Voucher", Rec.SystemId, Rec."Reference No.", VoucherType.PDFDesignerTemplateId)) then
                        Error(AddAssetFailed);

                    if (not DesignerFacade.GetManifestUrl(ManifestId, ManifestUrl)) then
                        Error(CreateUrlFailed);

                    Hyperlink(ManifestUrl);
                end;
            }
        }
    }
    var
        ReservedAmountVisible: Boolean;

    trigger OnOpenPage()
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        ReservedAmountVisible := NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled();
    end;
}
