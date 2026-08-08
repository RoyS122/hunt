
export type CompanyIndex = struct {
    head: ChunkHeader,

    name_size: u8,
    name: str,

    status: CompanyStatus,
    created_at: u64,
};
