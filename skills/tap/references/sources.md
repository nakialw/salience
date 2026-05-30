# tap — sources and lineage

## Why emphasis fails

- Liu et al. (2023). *Lost in the Middle: How Language Models Use Long Contexts.* arXiv:2307.03172.
- Zhou et al. (2023). *Instruction-Following Evaluation for Large Language Models (IFEval).* arXiv:2311.07911.

## Input emphasis (complementary, not substitute for tap)

- PASTA / post-hoc attention steering on user-highlighted spans.
- GUIDE — tagged spans + attention bias (arXiv:2409.19001).
- SpotLight — dynamic instruction emphasis (EACL 2026).
- Leviathan, Kalman & Matias (2025). *Prompt Repetition Improves Non-Reasoning LLMs.* arXiv:2512.14982.
- Anthropic. [Use XML tags](https://docs.anthropic.com/claude/docs/chain-prompts).

## Iterative critique (core mechanism)

- Madaan et al. (2023). *Self-Refine.* arXiv:2303.17651.
- Dhuliawala et al. (2023). *Chain-of-Verification (CoVe).* arXiv:2309.11495.
- Bai et al. (2022). *Constitutional AI.* arXiv:2212.08073.
- Shinn et al. (2023). *Reflexion.* arXiv:2303.11366.
- Gou et al. (2024). *CRITIC.* ICLR 2024.
- Asai et al. (2023). *Self-RAG.* arXiv:2310.11511.
- Yao et al. (2023). *Tree of Thoughts.* arXiv:2305.10601.

## Limits and risks

- Huang et al. (2024). *Large Language Models Cannot Self-Correct Reasoning Yet.* arXiv:2310.01798.
- Kamoi et al. (2024). *When Can LLMs Actually Correct Their Own Mistakes?* arXiv:2406.01297.
- Sharma et al. (2024). Sycophancy in language models. arXiv:2310.13548.
- Liang et al. (2024). MAD / Degeneration-of-Thought. arXiv:2305.19118.
- Du et al. (2023). Multi-agent debate. arXiv:2305.14325.

## Design mapping

| tap feature | Literature basis |
|-------------|------------------|
| Iterate draft → critique → revise | Self-Refine, Constitutional AI |
| Factored check before reading draft | CoVe (independent verification) |
| Verifiable taps → tools/checks | CRITIC, IFEval, Kamoi survey |
| Coverage + fidelity scores | Self-RAG segment critique |
| Min passes + cap + plateau stop | Self-Refine, MAD adaptive break |
| Anti-sycophancy critic | Sharma et al. |
| Honest limits on intrinsic review | Huang et al., Kamoi et al. |
| Step 1b compound-tap decomposition | CoVe claim breakdown; IFEval multi-constraint prompts |
