page 6059893 "NPR MM MembershipLoyaltyJnl"
{
    Caption = 'Membership Loyalty Journal';
    PageType = Worksheet;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    UsageCategory = Lists;
    SourceTable = "NPR MM MembershipLoyaltyJnl";
    AdditionalSearchTerms = 'Membership Points Adjustment,Membership Loyalty Adjustment';
    Extensible = False;

    layout
    {
        area(Content)
        {
            field(JournalNameFilter; _JournalName)
            {
                Caption = 'Journal Name';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'Enter a journal name to tag and filter your entries. Only entries with this filter will be posted.';
                trigger OnValidate()
                begin
                    Rec.Reset();
                    if (_JournalName <> '') then
                        Rec.SetFilter(JournalName, '=%1', _JournalName);
                    CurrPage.Update(false);
                end;
            }

            repeater(GroupName)
            {
                field(DocumentDate; Rec.DocumentDate)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Document Date field.';
                    trigger OnValidate()
                    begin
                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;
                }
                field(ExternalMembershipNo; Rec.ExternalMembershipNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the External Membership No. field.';

                    trigger OnValidate()
                    var
                        Membership: Record "NPR MM Membership";
                    begin
                        Membership.SetFilter("External Membership No.", '=%1', Rec.ExternalMembershipNo);
                        Membership.FindFirst();
                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(MembershipLookup(Text));
                    end;
                }
                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field(Type; Rec."Type")
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Type field.';
                    trigger OnValidate()
                    begin
                        if (Rec.Type = xRec.Type) then
                            exit;

                        if (Rec.Type <> Rec.Type::EARN) then begin
                            Rec.ItemNo := '';
                            Rec.UnitPrice := 0;
                            Rec.Quantity := 0;
                            Rec.AmountInclVat := 0;
                        end;

                        if (Rec.Type = Rec.Type::EARN) then
                            Rec.PointsToDepositOrWithdraw := 0;

                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;
                }
                field(PosUnitNo; Rec.PosUnitNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the POS Unit No. field.';
                }

                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field.';

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if (not Item.Get(Rec.ItemNo)) then
                            exit;

                        Rec.UnitPrice := Item."Unit Price";
                        Rec.Quantity := 1;
                        Rec.AmountInclVat := Rec.UnitPrice * Rec.Quantity;
                        if (not Item."Price Includes VAT") then
                            Rec.AmountInclVat := IncludeVat(Rec.UnitPrice * Rec.Quantity, Rec.ItemNo);
                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;
                }
                field(UnitPrice; Rec.UnitPrice)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Unit Price field.';

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if (not Item.Get(Rec.ItemNo)) then
                            exit;

                        Rec.AmountInclVat := Rec.UnitPrice * Rec.Quantity;
                        if (not Item."Price Includes VAT") then
                            Rec.AmountInclVat := IncludeVat(Rec.UnitPrice * Rec.Quantity, Rec.ItemNo);
                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Quantity field.';

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        if (not Item.Get(Rec.ItemNo)) then
                            exit;

                        Rec.AmountInclVat := Rec.UnitPrice * Rec.Quantity;
                        if (not Item."Price Includes VAT") then
                            Rec.AmountInclVat := IncludeVat(Rec.UnitPrice * Rec.Quantity, Rec.ItemNo);
                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;
                }
                field(AmountInclVat; Rec.AmountInclVat)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Amount Incl. VAT field.';

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                        VatError: Label 'Amount is VAT inclusive and must not be greater than unit price * quantity.';
                    begin
                        if (not Item.Get(Rec.ItemNo)) then begin
                            if (Rec.AmountInclVat > Rec.UnitPrice * Rec.Quantity) then
                                Error(VatError);
                            exit;
                        end;

                        Rec.AmountInclVat := Rec.UnitPrice * Rec.Quantity;
                        if (not Item."Price Includes VAT") then
                            Rec.AmountInclVat := IncludeVat(Rec.UnitPrice * Rec.Quantity, Rec.ItemNo);
                        CalculateEarnPoints(Rec, Rec.PointsToEarn);
                    end;
                }
                field(PointsToEarn; Rec.PointsToEarn)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Points To Earn field.';
                }
                field(PointsToDepositOrWithdraw; Rec.PointsToDepositOrWithdraw)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Points To Deposit or Withdraw field.';
                    trigger OnValidate()
                    var
                        IncorrectType: Label 'The field %1 can not be used when registering adjustment with type %2.';
                    begin
                        if (Rec.Type = Rec.Type::EARN) then
                            Error(IncorrectType, Rec.FieldCaption(PointsToDepositOrWithdraw), Rec.Type::EARN);
                    end;
                }
                field(Decription; Rec.Description)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Sales Channel"; Rec."Sales Channel")
                {
                    ToolTip = 'Specifies the value of the Sales Channel field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(JournalName; Rec.JournalName)
                {
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Journal Name field.';
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(Post)
            {
                Caption = 'Post';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This action posts the the proposed changes.';
                Image = Post;

                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    ConfirmPostJnl: Label 'Do you want to post the loyalty adjustment journal %1?';
                begin
                    if (Confirm(ConfirmPostJnl, true, _JournalName)) then
                        PostJnl(_JournalName);
                end;
            }
        }
        area(Navigation)
        {
            action(PointsEntry)
            {
                Caption = 'Membership Points Entry List';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ToolTip = 'This action navigates to the Points Entry List page';
                Image = Navigate;

                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                Scope = Repeater;

                trigger OnAction();
                var
                    PointEntryList: Page "NPR MM Members. Point Entry";
                    MembershipPointEntry: Record "NPR MM Members. Points Entry";
                    Membership: Record "NPR MM Membership";
                begin
                    if (Rec.ExternalMembershipNo <> '') then begin
                        Membership.SetFilter("External Membership No.", '=%1', Rec.ExternalMembershipNo);
                        Membership.FindFirst();
                        MembershipPointEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                        PointEntryList.SetTableView(MembershipPointEntry);
                    end;
                    PointEntryList.Run();
                end;
            }
        }
    }

    var
        _JournalName: Code[20];

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        DefaultDocumentNo: Label 'ADJUSTMENT', MaxLength = 20;
    begin
        Rec.DocumentDate := Today();
        Rec.DocumentNo := DefaultDocumentNo;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.JournalName := _JournalName;
    end;

    local procedure PostJnl(JournalToPost: Code[20])
    var
        MembershipLoyaltyJnl: Record "NPR MM MembershipLoyaltyJnl";
        TempMembershipLoyaltyJnl: Record "NPR MM MembershipLoyaltyJnl" temporary;
    begin
        // Process in sets of membership and document
        if (JournalToPost <> '') then
            MembershipLoyaltyJnl.SetFilter(JournalName, '=%1', JournalToPost);
        MembershipLoyaltyJnl.FindSet();
        repeat
            TempMembershipLoyaltyJnl.SetFilter(JournalName, '=%1', MembershipLoyaltyJnl.JournalName);
            TempMembershipLoyaltyJnl.SetFilter(ExternalMembershipNo, '=%1', MembershipLoyaltyJnl.ExternalMembershipNo);
            TempMembershipLoyaltyJnl.SetFilter(DocumentNo, '=%1', MembershipLoyaltyJnl.DocumentNo);
            if (TempMembershipLoyaltyJnl.IsEmpty()) then begin
                TempMembershipLoyaltyJnl.TransferFields(MembershipLoyaltyJnl, true);
                TempMembershipLoyaltyJnl.Insert();
            end;
        until (MembershipLoyaltyJnl.Next() = 0);

        TempMembershipLoyaltyJnl.Reset();
        TempMembershipLoyaltyJnl.FindSet();
        repeat
            MembershipLoyaltyJnl.SetCurrentKey(JournalName, ExternalMembershipNo, DocumentNo, Type);
            MembershipLoyaltyJnl.SetFilter(JournalName, '=%1', TempMembershipLoyaltyJnl.JournalName);
            MembershipLoyaltyJnl.SetFilter(ExternalMembershipNo, '=%1', TempMembershipLoyaltyJnl.ExternalMembershipNo);
            MembershipLoyaltyJnl.SetFilter(DocumentNo, '=%1', TempMembershipLoyaltyJnl.DocumentNo);
            MembershipLoyaltyJnl.FindSet();
            repeat
                CASE (MembershipLoyaltyJnl.Type) OF
                    MembershipLoyaltyJnl.Type::EARN:
                        RegisterEarnPoints(MembershipLoyaltyJnl);
                    MembershipLoyaltyJnl.Type::WITHDRAW:
                        WithdrawPoints(MembershipLoyaltyJnl);
                    MembershipLoyaltyJnl.Type::DEPOSIT:
                        DepositPoints(MembershipLoyaltyJnl);
                end;
            until (MembershipLoyaltyJnl.Next() = 0);

            MembershipLoyaltyJnl.DeleteAll();
            Commit();

        until (TempMembershipLoyaltyJnl.Next() = 0);
    end;

    local procedure RegisterEarnPoints(MembershipLoyaltyJnl: Record "NPR MM MembershipLoyaltyJnl")
    var
        Membership: Record "NPR MM Membership";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        AmountExclVat: Decimal;
        DiscAmtExclVat: Decimal;
    begin
        Membership.SetFilter("External Membership No.", '=%1', MembershipLoyaltyJnl.ExternalMembershipNo);
        Membership.FindFirst();
        Membership.TestField("Customer No.");
        AmountExclVat := ExcludeVat(MembershipLoyaltyJnl.AmountInclVat, MembershipLoyaltyJnl.ItemNo);
        DiscAmtExclVat := ExcludeVat(MembershipLoyaltyJnl.AmountInclVat - MembershipLoyaltyJnl.UnitPrice * MembershipLoyaltyJnl.Quantity, MembershipLoyaltyJnl.ItemNo);
        LoyaltyPointManagement.RegisterPoints(MembershipLoyaltyJnl.DocumentDate, Membership."Entry No.", MembershipLoyaltyJnl.POSUnitNo, MembershipLoyaltyJnl.ItemNo, MembershipLoyaltyJnl.Quantity, MembershipLoyaltyJnl.DocumentNo, AmountExclVat, DiscAmtExclVat, true, MembershipLoyaltyJnl."Sales Channel");
    end;

    local procedure WithdrawPoints(MembershipLoyaltyJnl: Record "NPR MM MembershipLoyaltyJnl")
    var
        Membership: Record "NPR MM Membership";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin
        Membership.SetFilter("External Membership No.", '=%1', MembershipLoyaltyJnl.ExternalMembershipNo);
        Membership.FindFirst();
        Membership.TestField("Customer No.");
        LoyaltyPointManagement.ManualRedeemPointsWithdraw(Membership."Entry No.", MembershipLoyaltyJnl.DocumentNo, MembershipLoyaltyJnl.PointsToDepositOrWithdraw, 0, Today(), MembershipLoyaltyJnl.DocumentDate, MembershipLoyaltyJnl.Description);
    end;

    local procedure DepositPoints(MembershipLoyaltyJnl: Record "NPR MM MembershipLoyaltyJnl")
    var
        Membership: Record "NPR MM Membership";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin
        Membership.SetFilter("External Membership No.", '=%1', MembershipLoyaltyJnl.ExternalMembershipNo);
        Membership.FindFirst();
        Membership.TestField("Customer No.");
        LoyaltyPointManagement.ManualRedeemPointsDeposit2(Membership."Entry No.", MembershipLoyaltyJnl.DocumentNo, MembershipLoyaltyJnl.PointsToDepositOrWithdraw, 0, Today(), MembershipLoyaltyJnl.DocumentDate, MembershipLoyaltyJnl.Description);
    end;

    local procedure CalculateEarnPoints(MembershipLoyaltyJnl: Record "NPR MM MembershipLoyaltyJnl"; var PointsEarned: Integer)
    var
        Membership: Record "NPR MM Membership";
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
        RuleReference: Integer;
        AwardedAmount: Decimal;
        AwardedPoints: Integer;
    begin
        if (MembershipLoyaltyJnl.Type <> MembershipLoyaltyJnl.Type::EARN) then begin
            PointsEarned := 0;
            exit;
        end;

        if (MembershipLoyaltyJnl.ItemNo = '') then
            exit;

        if (MembershipLoyaltyJnl.ExternalMembershipNo = '') then
            exit;

        Membership.SetFilter("External Membership No.", '=%1', MembershipLoyaltyJnl.ExternalMembershipNo);
        if (not Membership.FindFirst()) then
            exit;

        if (MembershipLoyaltyJnl.Quantity = 0) then begin
            PointsEarned := 0;
            exit;
        end;

        LoyaltyPointManagement.CalculatePointsForTransactions(Membership."Entry No.", MembershipLoyaltyJnl.DocumentDate, MembershipLoyaltyJnl.ItemNo, '', MembershipLoyaltyJnl.Quantity, MembershipLoyaltyJnl.AmountInclVAT, false, MembershipLoyaltyJnl."Sales Channel", AwardedAmount, AwardedPoints, PointsEarned, RuleReference);
    end;

    local procedure ExcludeVat(ParamAmountInclVat: Decimal; ParamItemNo: Code[20]) AmountBase: Decimal
    var
        Item: Record "Item";
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        // Hard error on missing data
        Item.Get(ParamItemNo);
        VatPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Item."VAT Bus. Posting Gr. (Price)");
        VatPostingSetup.SetFilter("VAT Prod. Posting Group", '=%1', Item."VAT Prod. Posting Group");
        VatPostingSetup.FindFirst();

        AmountBase := ParamAmountInclVat / ((100 + VatPostingSetup."VAT %") / 100.0);
    end;

    local procedure IncludeVat(AmountBase: Decimal; ParamItemNo: Code[20]) AmountInclVat: Decimal
    var
        Item: Record "Item";
        VatPostingSetup: Record "VAT Posting Setup";
    begin
        // Hard error on missing data
        Item.Get(ParamItemNo);
        VatPostingSetup.SetFilter("VAT Bus. Posting Group", '=%1', Item."VAT Bus. Posting Gr. (Price)");
        VatPostingSetup.SetFilter("VAT Prod. Posting Group", '=%1', Item."VAT Prod. Posting Group");
        VatPostingSetup.FindFirst();

        AmountInclVat := AmountBase * ((100 + VatPostingSetup."VAT %") / 100.0);
    end;

    local procedure MembershipLookup(var ParamExternalMembershipNo: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipListPage: Page "NPR MM Memberships";
        PageAction: Action;
    begin
        Membership.SetFilter(Blocked, '=%1', false);
        MembershipListPage.SetTableView(Membership);
        MembershipListPage.LookupMode(true);
        PageAction := MembershipListPage.RunModal();

        if (PageAction <> Action::LookupOK) then
            exit(false);

        MembershipListPage.GetRecord(Membership);
        ParamExternalMembershipNo := Membership."External Membership No.";
        exit(true);
    end;
}