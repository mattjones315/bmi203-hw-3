using FastaIO;
using DataFrames;

"""
Base.parse_input(seq_fp1::String, seq_fp2::String, sm_fp::String)
Read in FASTA files from SEQ_FP1 and SEQ_FP2 and the substitution matrix
stored in SM_FP.

"""
function parse_input(seq_fp1, seq_fp2, sm_fp)

    seq1 = readfasta(seq_fp1)[1][2];
    seq2 = readfasta(seq_fp2)[1][2];

    sm = parse_score_matrix(sm_fp);

    seq1, seq2, sm
end

function parse_score_matrix(sm_fp)

    f = open(sm_fp);
    lines = readlines(f);
    i = 1
    while lines[i][1] == '#'
        i += 1
    end
    aas = strip.(split(lines[i], "  "));
    i += 1

    N = length(aas);

    #sm = DataFrame(zeros(N));
    sm = DataFrame(Float64, 0, N);
    nframe = DataFrame(AA = aas);

    while i <= length(lines)

        sub = strip.(split(lines[i]));
        sub = parse.(Float64, sub);
        push!(sm, sub);
        i += 1
    end

    close(f)
    #deleterows!(sm, 1);
    names!(sm, [Symbol(aa) for aa in aas]);
    sm = hcat(nframe, sm);

    sm

end

function parse_seq_list(seqs_fp, sm_fp)

    seqs = []

    f = open(seqs_fp)
    lines = readlines(f)

    for l in lines
        seq_pair = strip.(split(l));
        seq_pair = convert.(String, seq_pair);
        seq1 = readfasta(seq_pair[1])[1][2]
        seq2 = readfasta(seq_pair[2])[1][2];
        push!(seqs, [seq1, seq2])
    end

    close(f)

    sm = parse_score_matrix(sm_fp)

    seqs, sm

end