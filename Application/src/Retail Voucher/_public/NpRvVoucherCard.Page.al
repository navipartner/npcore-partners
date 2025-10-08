page 6151014 "NPR NpRv Voucher Card"
{
    Extensible = true;
    UsageCategory = None;
    Caption = 'Retail Voucher Card';
    ContextSensitiveHelpPage = 'docs/retail/vouchers/explanation/voucher_types/';
    SourceTable = "NPR NpRv Voucher";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014426)
                {
                    ShowCaption = false;
                    field("No."; Rec."No.")
                    {
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number of the voucher.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Type"; Rec."Voucher Type")
                    {
                        ToolTip = 'Specifies the type of the voucher. Credit and gift vouchers are default, but additional ones can be defined as well.';
                        ApplicationArea = NPRRetail;
#if not BC17

                        trigger OnValidate()
                        begin
                            UpdateShopifyControls();
                        end;
#endif
                    }
                    field(Description; Rec.Description)
                    {
                        ToolTip = 'Specifies the description of the voucher.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Account No."; Rec."Account No.")
                    {
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number of the account associated with the voucher.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Register No."; Rec."Issue Register No.")
                    {
                        ToolTip = 'Specifies the value of the Issue Register No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Document Type"; Rec."Issue Document Type")
                    {
                        ToolTip = 'Specifies the value of the Issue Document Type field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Document No."; Rec."Issue Document No.")
                    {
                        ToolTip = 'Specifies the value of the Issue Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue External Document No."; Rec."Issue External Document No.")
                    {
                        ToolTip = 'Specifies the value of the Issue External Document No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Issue Partner Code"; Rec."Issue Partner Code")
                    {
                        ToolTip = 'Specifies the value of the Issue Partner Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Partner Clearing"; Rec."Partner Clearing")
                    {
                        ToolTip = 'Specifies the value of the Partner Clearing field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Allow Top-up"; Rec."Allow Top-up")
                    {
                        ToolTip = 'Specifies the value of the Allow Top-up field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Disabled for Web Service"; Rec."Disabled for Web Service")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Disabled for Web Service field. Web shops usually interact with web service.';
                    }

                }
                group(Control6014422)
                {
                    ShowCaption = false;
                    field("Issue Date"; Rec."Issue Date")
                    {
                        ToolTip = 'Specifies the value of the Issue Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Open; Rec.Open)
                    {
                        ToolTip = 'Specifies if the voucher is open or not.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Initial Amount"; Rec."Initial Amount")
                    {
                        Editable = false;
                        ToolTip = 'Specifies the value of the Initial Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Amount; Rec.Amount)
                    {
                        ToolTip = 'Specifies the value of the Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Reserved Amount"; Rec."Reserved Amount")
                    {
                        Visible = ReservedAmountVisible;
                        ToolTip = 'Specifies the value of the Reserved Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field("In-use Quantity"; Rec."In-use Quantity")
                    {
                        ToolTip = 'Specifies the value of the In-use Quantity field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Comment; Rec.Comment)
                    {
                        ToolTip = 'This field allows users to provide custom comments about the Voucher. It is used to enter any additional information or notes related to the Voucher.';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Send Voucher")
            {
                Caption = 'Send Voucher';
                group(Control6014417)
                {
                    ShowCaption = false;
                    field("Send Voucher Module"; Rec."Send Voucher Module")
                    {
                        ToolTip = 'Specifies the value of the Send Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014415)
                {
                    ShowCaption = false;
                    field("Reference No."; Rec."Reference No.")
                    {
                        ToolTip = 'Specifies the value of the Reference No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send via Print"; Rec."Send via Print")
                    {
                        ToolTip = 'Specifies the value of the Send via Print field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Object Type"; Rec."Print Object Type")
                    {
                        Enabled = Rec."Send via Print";
                        ToolTip = 'Specifies the print object type for the voucher type';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            UpdateControls();
                        end;
                    }
                    field("Print Object ID"; Rec."Print Object ID")
                    {
                        Enabled = Rec."Send via Print" and not PrintUsingTemplate;
                        ToolTip = 'Specifies the print object Id for the voucher type';
                        ApplicationArea = NPRRetail;
                    }
                    field("Print Template Code"; Rec."Print Template Code")
                    {
                        Enabled = Rec."Send via Print" and PrintUsingTemplate;
                        ToolTip = 'Specifies the value of the Print Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send via E-mail"; Rec."Send via E-mail")
                    {
                        ToolTip = 'Specifies the value of the Send via E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template Code"; Rec."E-mail Template Code")
                    {
                        Visible = not NewEmailExperience;
                        Enabled = Rec."Send via E-mail";
                        ToolTip = 'Specifies the value of the E-mail Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail Template Id"; Rec."E-mail Template Id")
                    {
                        Visible = NewEmailExperience;
                        Enabled = Rec."Send via E-mail";
                        ToolTip = 'Specifies the E-mail Template Id used when sending the voucher';
                        ApplicationArea = NPRRetail;
                    }
                    field("Send via SMS"; Rec."Send via SMS")
                    {
                        ToolTip = 'Specifies the value of the Send via SMS field';
                        ApplicationArea = NPRRetail;
                    }
                    field("SMS Template Code"; Rec."SMS Template Code")
                    {
                        Enabled = Rec."Send via SMS";
                        ToolTip = 'Specifies the value of the SMS Template Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("No. Send"; Rec."No. Send")
                    {
                        ToolTip = 'Specifies the value of the No. Send field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Contact)
                {
                    Caption = 'Contact';
                    field("Customer No."; Rec."Customer No.")
                    {
                        ToolTip = 'Specifies the value of the Customer No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Contact No."; Rec."Contact No.")
                    {
                        ToolTip = 'Specifies the value of the Contact No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {
                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Name 2"; Rec."Name 2")
                    {
                        ToolTip = 'Specifies the value of the Name 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Address; Rec.Address)
                    {
                        ToolTip = 'Specifies the value of the Address field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Address 2"; Rec."Address 2")
                    {
                        ToolTip = 'Specifies the value of the Address 2 field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Post Code"; Rec."Post Code")
                    {
                        ToolTip = 'Specifies the value of the Post Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(City; Rec.City)
                    {
                        ToolTip = 'Specifies the value of the City field';
                        ApplicationArea = NPRRetail;
                    }
                    field(County; Rec.County)
                    {
                        ToolTip = 'Specifies the value of the County field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Country/Region Code"; Rec."Country/Region Code")
                    {
                        ToolTip = 'Specifies the value of the Country/Region Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("E-mail"; Rec."E-mail")
                    {
                        ToolTip = 'Specifies the value of the E-mail field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Phone No."; Rec."Phone No.")
                    {
                        ToolTip = 'Specifies the value of the Phone No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Language Code"; Rec."Language Code")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the value of the Language Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Voucher Message"; Rec."Voucher Message")
                    {
                        MultiLine = true;
                        ToolTip = 'Specifies the value of the Voucher Message field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Validate Voucher")
            {
                Caption = 'Validate Voucher';
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Validate Voucher Module"; Rec."Validate Voucher Module")
                    {
                        ToolTip = 'Specifies the value of the Validate Voucher Module field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014409)
                {
                    ShowCaption = false;
                    field("Starting Date"; Rec."Starting Date")
                    {
                        ToolTip = 'Specifies the value of the Starting Date field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Ending Date"; Rec."Ending Date")
                    {
                        ToolTip = 'Specifies the value of the Ending Date field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group("Apply Payment")
            {
                Caption = 'Apply Payment';
                field("Apply Payment Module"; Rec."Apply Payment Module")
                {
                    ToolTip = 'Specifies whether the payment module application is DEFAULT or PARTIAL. DEFAULT implies that the retail voucher amount will be accepted in total when redeeming. PARTIAL implies the retail voucher amount is accepted partially when redeeming. The difference remains on the voucher and can be used later.';
                    ApplicationArea = NPRRetail;
                }
            }
#if not BC17
            group(Shopify)
            {
                Caption = 'Shopify';
                Visible = ShopifyIntegrationIsEnabled and VourcherTypeShopifyIntegrationIsEnabled;
                field("Shopify Gift Card ID"; ShopifyGiftCardID)
                {
                    Caption = 'Shopify Gift Card ID';
                    Editable = false;
                    AssistEdit = true;
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the value of the Shopify Gift Card ID field.';

                    trigger OnAssistEdit()
                    var
                        ChangeShopifyID: Page "NPR Spfy Change Assigned ID";
                    begin
                        SpfyRetailVoucherMgt.TestRequiredFields(Rec);
                        CurrPage.SaveRecord();
                        Commit();

                        Clear(ChangeShopifyID);
                        ChangeShopifyID.SetOptions(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
                        ChangeShopifyID.RunModal();

                        CurrPage.Update(false);
                    end;
                }
                group(SendFromShopify)
                {
                    ShowCaption = false;
                    field("Spfy Send from Shopify"; Rec."Spfy Send from Shopify")
                    {
                        ToolTip = 'Specifies whether you want the voucher to be sent to the recipient’s email address via Shopify. If enabled, the system will use the email address, customer name and voucher message from the voucher card to send the voucher to the recipient.';
                        ApplicationArea = NPRShopify;
                        Editable = ShopifyGiftCardID = '';
                    }
                    field("Spfy Recipient Name"; Rec."Spfy Recipient Name")
                    {
                        ToolTip = 'Specifies the name of the voucher recipient. If this field is empty, the system will use the customer name from the voucher card.';
                        ApplicationArea = NPRShopify;
                        Enabled = Rec."Spfy Send from Shopify";
                        Editable = ShopifyGiftCardID = '';
                    }
                    field("Spfy Recipient E-mail"; Rec."Spfy Recipient E-mail")
                    {
                        ToolTip = 'Specifies the email address of the voucher recipient. If this field is empty, the system will use the customer email address from the voucher card.';
                        ApplicationArea = NPRShopify;
                        Enabled = Rec."Spfy Send from Shopify";
                        Editable = ShopifyGiftCardID = '';
                    }
                    field("Spfy Send on"; Rec."Spfy Send on")
                    {
                        ToolTip = 'Specifies the date and time when Shopify should send the voucher to the recipient.';
                        ApplicationArea = NPRShopify;
                        Enabled = Rec."Spfy Send from Shopify";
                        Editable = ShopifyGiftCardID = '';
                    }
                }
            }
#endif
        }
    }

    actions
    {
        area(processing)
        {
            group(SendGroup)
            {
                Caption = '&Send';
                Image = Post;
                action(SendVoucher)
                {
                    Caption = 'Send Voucher';
                    Image = SendTo;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Executes the Send Voucher action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    begin
                        Codeunit.Run(codeunit::"NPR NpRv Voucher Mgt.", Rec);
                    end;
                }
            }
            action("Reset Vouchers In-use")
            {
                Caption = 'Reset Vouchers In-use';
                Image = RefreshVoucher;
                Visible = PageActionResetQuantityVisible;
                ToolTip = 'Executes the Reset Vouchers In-use action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                    ConfirmManagement: Codeunit "Confirm Management";
                    DeleteVouchersQst: Label 'Are you sure you want to delete vouchers in-use?';
                begin
                    if not ConfirmManagement.GetResponseOrDefault(DeleteVouchersQst, false) then
                        exit;

                    NpRvVoucherMgt.ResetInUseQty(Rec);
                end;
            }
            group(ArchiveGroup)
            {
                Caption = '&Archive';
                Image = Post;
                action("Archive Coupon")
                {
                    Caption = 'Archive Voucher';
                    Image = Post;
                    ToolTip = 'Executes the Archive Voucher action';
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        Voucher: Record "NPR NpRv Voucher";
                        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
                        ConfirmManagement: Codeunit "Confirm Management";
                        ArchiveVoucherQst: Label 'Archive voucher manually?';
                    begin
                        if not ConfirmManagement.GetResponseOrDefault(ArchiveVoucherQst, false) then
                            exit;

                        Voucher.Get(Rec."No.");
                        NpRvVoucherMgt.ArchiveVouchers(Voucher);
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
                ToolTip = 'Executes the Voucher Entries action';
                ApplicationArea = NPRRetail;
            }
            action("Sending Log")
            {
                Caption = 'Sending Log';
                Image = Log;
                RunObject = Page "NPR NpRv Sending Log";
                RunPageLink = "Voucher No." = FIELD("No.");
                ShortCutKey = 'Shift+Ctrl+F7';
                ToolTip = 'Executes the Sending Log action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        PrintUsingTemplate: Boolean;

        ReservedAmountVisible: Boolean;
        PageActionResetQuantityVisible: Boolean;
        NewEmailExperience: Boolean;
#if not BC17
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        ShopifyGiftCardID: Text[30];
        ShopifyIntegrationIsEnabled: Boolean;
        VourcherTypeShopifyIntegrationIsEnabled: Boolean;
#endif

    trigger OnOpenPage()
    var
#if not BC17
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        NewEmailExperienceFeature: Codeunit "NPR NewEmailExpFeature";
#endif
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
#if not BC17
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers");
#endif
        ReservedAmountVisible := NpRvVoucherMgt.VoucherReservationByAmountFeatureEnabled();
        PageActionResetQuantityVisible := not ReservedAmountVisible;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        NewEmailExperience := NewEmailExperienceFeature.IsFeatureEnabled()
#endif
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
#if not BC17
        ShopifyGiftCardID := '';
        VourcherTypeShopifyIntegrationIsEnabled := false;
#endif

    end;


    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
#if not BC17
        UpdateShopifyControls();
#endif
    end;

    local procedure UpdateControls()
    begin
        PrintUsingTemplate := Rec."Print Object Type" = Rec."Print Object Type"::Template;
    end;

#if not BC17
    local procedure UpdateShopifyControls()
    begin
        ShopifyGiftCardID := SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        VourcherTypeShopifyIntegrationIsEnabled := SpfyRetailVoucherMgt.IsShopifyIntegratedVoucherType(Rec."Voucher Type");
    end;
#endif
}
