xmlport 6060142 "NPR MM Member Identifier"
{

    Caption = 'MM Member Identifier';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    schema
    {
        textelement(MemberIdentifier)
        {
            textelement(Resolve)
            {
                tableelement(tmpininfocapture; "NPR MM Member Info Capture")
                {
                    XmlName = 'Identifier';
                    UseTemporary = true;
                    fieldattribute(Value; TmpInInfoCapture."Import Entry Document ID")
                    {
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        TmpInInfoCapture."Entry No." := TmpInInfoCapture.Count() + 1;
                    end;
                }
            }
            textelement(Result)
            {
                MinOccurs = Zero;
                tableelement(tmpoutinfocapture; "NPR MM Member Info Capture")
                {
                    XmlName = 'Identifier';
                    UseTemporary = true;
                    fieldattribute(Value; TmpOutInfoCapture."Import Entry Document ID")
                    {
                    }
                    textelement(ValueIs)
                    {

                        trigger OnBeforePassVariable()
                        var
                            PlaceHolderLbl: Label '%1|%2', Locked = true;
                        begin
                            ValueIs := '';
                            if (TmpOutInfoCapture."External Membership No." <> '') then
                                ValueIs := 'membershipnumber';

                            if (TmpOutInfoCapture."External Member No" <> '') then
                                ValueIs := StrSubstNo(PlaceHolderLbl, ValueIs, 'membernumber');

                            if (TmpOutInfoCapture."External Card No." <> '') then
                                ValueIs := StrSubstNo(PlaceHolderLbl, ValueIs, 'cardnumber');

                            ValueIs := DelChr(ValueIs, '<', '|');

                            if (ValueIs = '') then
                                ValueIs := 'invalidnumber';
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    procedure CreateResult()
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
    begin
        if (TmpInInfoCapture.FindSet()) then begin
            repeat
                TmpOutInfoCapture.Init();
                TmpOutInfoCapture."Entry No." := TmpInInfoCapture."Entry No.";
                TmpOutInfoCapture."Import Entry Document ID" := TmpInInfoCapture."Import Entry Document ID";

                Member.SetFilter("External Member No.", '=%1', CopyStr(TmpOutInfoCapture."Import Entry Document ID", 1, MaxStrLen(Member."External Member No.")));
                if (Member.FindFirst()) then
                    TmpOutInfoCapture."External Member No" := Member."External Member No.";

                Membership.SetFilter("External Membership No.", '=%1', CopyStr(TmpOutInfoCapture."Import Entry Document ID", 1, MaxStrLen(Membership."External Membership No.")));
                if (Membership.FindFirst()) then
                    TmpOutInfoCapture."External Membership No." := Membership."External Membership No.";

                MemberCard.SetFilter("External Card No.", '=%1', CopyStr(TmpOutInfoCapture."Import Entry Document ID", 1, MaxStrLen(MemberCard."External Card No.")));
                if (MemberCard.FindFirst()) then
                    TmpOutInfoCapture."External Card No." := MemberCard."External Card No.";

                TmpOutInfoCapture.Insert();
            until (TmpInInfoCapture.Next() = 0);
        end;
    end;
}

