﻿codeunit 6060134 "NPR MM POS Receipt Print"
{
    Access = Internal;

    TableNo = "NPR MM Membership";

    trigger OnRun()
    var
        TempPrinterDeviceSettings: Record "NPR Printer Device Settings" temporary;
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        Voided: Text;
        PlaceHolderLbl: Label '%1 - %2', Locked = true;
    begin
        Membership.CopyFilters(Rec);

        Printer.SetAutoLineBreak(true);
        Printer.SetThreeColumnDistribution(0.465, 0.35, 0.235);

        if Membership.FindSet() then
            repeat
                Printer.SetFont('COMMAND');
                Printer.AddLine('STOREDLOGO_1', 0);
                Printer.SetFont('A11');
                Printer.SetPadChar('.');
                Printer.AddLine('', 0);
                Printer.SetPadChar('');
                Printer.AddLine(' ', 0);

                Printer.SetBold(true);
                Printer.AddTextField(1, 0, MEMBERSHIP_TEXT);
                Printer.AddTextField(2, 2, Membership."External Membership No.");

                MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                if (MembershipEntry.FindSet()) then begin
                    repeat

                        Voided := '';
                        if (MembershipEntry.Blocked) then
                            Voided := VOID;
                        if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then
                            Voided := VOID;

                        Printer.AddTextField(1, 0, StrSubstNo(VALID_PERIOD, Voided));
                        Printer.AddTextField(2, 2, StrSubstNo(PlaceHolderLbl, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date"));
                    until (MembershipEntry.Next() = 0);
                end;

                Printer.AddLine(' ', 0);
                Printer.SetBold(false);
                MemberRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                if (MemberRole.FindSet()) then begin
                    repeat
                        if (Member.Get(MemberRole."Member Entry No.")) then begin
                            Printer.AddTextField(1, 0, '   ' + Member."External Member No.");
                            Printer.AddTextField(2, 2, Member."Display Name");
                        end;
                    until (MemberRole.Next() = 0);
                end;

                Printer.SetFont('COMMAND');
                Printer.AddLine('PAPERCUT', 0);
            until Membership.Next() = 0;

        Printer.ProcessBuffer(Codeunit::"NPR MM POS Receipt Print", Enum::"NPR Line Printer Device"::Epson, TempPrinterDeviceSettings);
    end;

    var
        Printer: Codeunit "NPR RP Line Print Mgt.";
        Membership: Record "NPR MM Membership";
        MEMBERSHIP_TEXT: Label 'Membership:';
        VALID_PERIOD: Label 'Valid period: %1';
        VOID: Label '(void)';
}

