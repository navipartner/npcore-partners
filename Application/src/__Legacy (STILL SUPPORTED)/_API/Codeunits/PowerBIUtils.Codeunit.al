codeunit 6184627 "NPR PowerBI Utils"
{
    Access = Internal;

    internal procedure GetSystemModifedAt(ModifiedAt: DateTime): DateTime
    begin
        if ModifiedAt < CreateDateTime(19800101D, 0T) then
            exit(CreateDateTime(19800101D, 0T));
        exit(ModifiedAt);
    end;
}
