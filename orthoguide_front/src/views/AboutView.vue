<template>
  <div class="about">
    <div class="text-section">
      <h3>About OrthoGuide</h3>
      <p>
        Correctly rooting a phylogenetic tree is a critical step in evolutionary biology, but it's
        often a slow and computationally intensive process. This can create a significant bottleneck
        for research.
      </p>
      <p>
        OrthoGuide eliminates this bottleneck by providing immediate access to high-quality,
        pre-computed rooting data. Instead of running complex analyses, users can query our database
        and get the information they need in seconds.
      </p>
      <p>
        All data in our database is generated using the
        <a href="https://github.com/sysbiolab/GeneBridge" target="_blank" rel="noopener noreferrer"
          >GeneBridge R package</a
        >, a method that infers a gene's evolutionary root based on the distribution of its
        orthologs. This approach does not require an outgroup, making it ideal for large-scale
        analyses.
      </p>
    </div>
    <div class="text-section">
      <h3>Citation</h3>
      <p>
        If you use data from OrthoGuide in your research, please cite the foundational paper for the
        Bridge algorithm:
      </p>
      <p>
        Campos, L. R. S., Trefflich, S., Morais, D. A. A., Imparato, D. O., Chagas, V. S., Albanus,
        R. D., Dalmolin, R. J. S., & Castro, M. A. A. (2024). Bridge: A New Algorithm for Rooting
        Orthologous Genes in Large-Scale Evolutionary Analyses. Molecular Biology and Evolution,
        41(2), msae019.
        <a href="https://doi.org/10.1093/molbev/msae019" target="_blank">10.1093/molbev/msae019</a>
      </p>
    </div>
  </div>
</template>

<style scoped>
.about {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
}

.about > div {
  margin: 0 1em;
  width: 50%;
}

p {
  font-size: 12px;
}

.text-section > p {
  margin: 1em 0;
}
</style>
