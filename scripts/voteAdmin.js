
const proposeAdmin = async (address) => {
  const data = await finalizeAdminAdminContract.methods
    .proposeAdmin(
      address
    )
    .send({ from: account });
  console.log(data);
};
const finalizeAdmin = async () => {
  const data = await finalizeAdminAdminContract.methods
    .finalizeAdmin(
  )
    .send({ from: account });
  console.log(data);
};
const startVoting = async () => {
  const data = await finalizeAdminAdminContract.methods
    .startVoting(
  )
    .send({ from: account });
  console.log(data);
};

const voteForAdmin = async () => {
  const data = await finalizeAdminAdminContract.methods
    .voteForAdmin(
  )
    .send({ from: account });
  console.log(data);
};
