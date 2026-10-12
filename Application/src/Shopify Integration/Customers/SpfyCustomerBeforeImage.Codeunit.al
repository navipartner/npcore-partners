codeunit 6151314 "NPR Spfy Customer Before Image"
{
    // Carries the on-disk customer from OnBeforeModifyEvent to OnAfterModifyEvent without touching xRec.
    // A stack, so a nested modify of the same customer takes its own image; record variables, so no Customer events fire.
    Access = Internal;
    SingleInstance = true;

    var
        _Images: array[20] of Record Customer;
        _ImageCount: Integer;

    internal procedure Remember(BeforeImage: Record Customer)
    var
        i: Integer;
    begin
        // A full stack only holds images left behind by modifies that failed, at the bottom; drop the oldest.
        if _ImageCount = ArrayLen(_Images) then begin
            for i := 1 to _ImageCount - 1 do
                _Images[i] := _Images[i + 1];
            _ImageCount -= 1;
        end;
        _ImageCount += 1;
        _Images[_ImageCount] := BeforeImage;
    end;

    /// <summary>Hands out the image remembered most recently for the customer and forgets it. False when nothing was remembered.</summary>
    internal procedure Take(CustomerNo: Code[20]; var BeforeImage: Record Customer): Boolean
    var
        i: Integer;
        j: Integer;
    begin
        for i := _ImageCount downto 1 do
            if _Images[i]."No." = CustomerNo then begin
                BeforeImage := _Images[i];
                for j := i to _ImageCount - 1 do
                    _Images[j] := _Images[j + 1];
                Clear(_Images[_ImageCount]);
                _ImageCount -= 1;
                exit(true);
            end;
        exit(false);
    end;
}
