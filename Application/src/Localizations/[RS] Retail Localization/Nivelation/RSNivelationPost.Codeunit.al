codeunit 6151343 "NPR RS Nivelation Post"
{
    Access = Internal;
#if not (BC17 or BC18 or BC19)
    procedure RunNivelationPosting(NivelationHeader: Record "NPR RS Nivelation Header")
    var
        PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr";
        SuccessfulPostingMsg: Label 'Successfully posted a Nivelation Document %1 for %2', Comment = '%1 = Nivelation Header No., %2 = Reffering Document Code';
    begin
        if PostNivelationDocument(NivelationHeader, PostedNivelationHeader) then
            Message(StrSubstNo(SuccessfulPostingMsg, PostedNivelationHeader."No.", NivelationHeader."Referring Document Code"));
    end;

    local procedure PostNivelationDocument(NivelationHeader: Record "NPR RS Nivelation Header"; var PostedNivelationHeader: Record "NPR RS Posted Nivelation Hdr"): Boolean
    var
        PostedNivelationLines: Record "NPR RS Posted Nivelation Lines";
        NivelationLines: Record "NPR RS Nivelation Lines";
        NivelationPosting: Codeunit "NPR RS Niv. Post Entries";
        LineNo: Integer;
    begin
        PostedNivelationHeader.Init();
        PostedNivelationHeader.TransferFields(NivelationHeader, false);
        NivelationHeader.CalcFields(Amount);
        PostedNivelationHeader.Amount := NivelationHeader.Amount;
        PostedNivelationHeader.Insert(true);

        LineNo := PostedNivelationLines.GetInitialLine() + 10000;

        NivelationLines.SetRange("Document No.", NivelationHeader."No.");
        NivelationLines.SetFilter(Quantity, '>0');
        if not NivelationLines.FindSet() then
            exit(false);
        repeat
            PostedNivelationLines.Init();
            PostedNivelationLines."Line No." := LineNo;
            PostedNivelationLines.TransferFields(NivelationLines);
            PostedNivelationLines."Document No." := PostedNivelationHeader."No.";
            PostedNivelationLines.Insert(true);
            LineNo += 10000;
        until NivelationLines.Next() = 0;
        NivelationPosting.PostNivelationEntries(PostedNivelationHeader);
        NivelationHeader.Delete();
        NivelationLines.DeleteAll();
        exit(true);
    end;
#endif
}