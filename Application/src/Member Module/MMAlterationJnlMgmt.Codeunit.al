codeunit 6060094 "NPR MM Alteration Jnl Mgmt"
{

    TableNo = "NPR MM Member Info Capture";

    trigger OnRun()
    begin

        AlterMembership(Rec);
    end;

    var
        NOT_SUPPORTED: Label '%1 %2 is not supported.';
        RequestUserConfirmation: Boolean;
        NOT_FOUND: Label '%1 %2 was not found.';

    procedure AlterMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        ReasonText: Text;
    begin

        if (MemberInfoCapture."Source Type" <> MemberInfoCapture."Source Type"::ALTERATION_JNL) then
            Error(NOT_SUPPORTED, MemberInfoCapture.FieldName("Source Type"), MemberInfoCapture."Source Type");

        case MemberInfoCapture."Response Status" of

            MemberInfoCapture."Response Status"::FAILED,
            MemberInfoCapture."Response Status"::REGISTERED:
                begin
                    MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;

                    if (CheckAlteration(MemberInfoCapture."Entry No.", RequestUserConfirmation, ReasonText)) then
                        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::READY;
                end;

            MemberInfoCapture."Response Status"::READY:
                begin
                    MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::FAILED;
                    if (ExecuteAlteration(MemberInfoCapture."Entry No.", RequestUserConfirmation, ReasonText)) then
                        MemberInfoCapture."Response Status" := MemberInfoCapture."Response Status"::COMPLETED;
                end;
        end;
        MemberInfoCapture."Response Message" := CopyStr(ReasonText, 1, MaxStrLen(MemberInfoCapture."Response Message"));
    end;

    local procedure ExecuteAlteration(MemberInfoCaptureEntryNo: Integer; WithConfirm: Boolean; var ReasonMessage: Text): Boolean
    begin

        exit(ProcessAlteration(MemberInfoCaptureEntryNo, true, WithConfirm, ReasonMessage));
    end;

    local procedure CheckAlteration(MemberInfoCaptureEntryNo: Integer; WithConfirm: Boolean; var ReasonMessage: Text): Boolean
    begin

        exit(ProcessAlteration(MemberInfoCaptureEntryNo, false, WithConfirm, ReasonMessage));
    end;

    local procedure ProcessAlteration(MemberInfoCaptureEntryNo: Integer; WithUpdate: Boolean; WithConfirm: Boolean; var ReasonMessage: Text) AlterOk: Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        UnitPrice: Decimal;
    begin

        MemberInfoCapture.Get(MemberInfoCaptureEntryNo);

        //Membership.Get() (MemberInfoCapture."Membership Entry No.");
        if (not Membership.Get(MemberInfoCapture."Membership Entry No.")) then begin
            ReasonMessage := StrSubstNo(NOT_FOUND, Membership.TableCaption, MemberInfoCapture."External Membership No.");
            exit(false);
        end;

        case MemberInfoCapture."Information Context" of

            MemberInfoCapture."Information Context"::REGRET:
                begin
                    AlterOk := MembershipManagement.RegretMembershipVerbose(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice, ReasonMessage);
                end;

            MemberInfoCapture."Information Context"::RENEW:
                begin
                    AlterOk := MembershipManagement.RenewMembershipVerbose(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice, ReasonMessage);
                end;

            MemberInfoCapture."Information Context"::UPGRADE:
                begin
                    AlterOk := MembershipManagement.UpgradeMembershipVerbose(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice, ReasonMessage);
                end;

            MemberInfoCapture."Information Context"::EXTEND:
                begin
                    AlterOk := MembershipManagement.ExtendMembershipVerbose(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice, ReasonMessage);
                end;

            MemberInfoCapture."Information Context"::CANCEL:
                begin
                    AlterOk := MembershipManagement.CancelMembershipVerbose(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice, ReasonMessage);
                end;

        end;
        if (not AlterOk) then
            exit(false);

        exit(true);
    end;

    procedure SetRequestUserConfirmation(WithConfirm: Boolean)
    begin

        RequestUserConfirmation := WithConfirm;
    end;
}

