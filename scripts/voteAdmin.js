
const proposeAdmin = async (address) => {
  const data = await voteAdminContract.methods
    .proposeAdmin(
      address
    )
    .send({ from: account });
  console.log(data);
};
const finalizeAdmin = async () => {
  const data = await voteAdminContract.methods
    .finalizeAdmin(
  )
    .send({ from: account });
  console.log(data);
};
const startVoting = async () => {
  const data = await voteAdminContract.methods
    .startVoting(
  )
    .send({ from: account });
  console.log(data);
};

const voteForAdmin = async () => {
  const data = await voteAdminContract.methods
    .voteForAdmin(
  )
    .send({ from: account });
  console.log(data);
};
