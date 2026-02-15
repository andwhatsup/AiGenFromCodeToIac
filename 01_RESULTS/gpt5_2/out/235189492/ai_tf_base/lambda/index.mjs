import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

export const handler = async (event) => {
  const iterator = event?.iterator ?? { index: 0, count: 0 };
  const index = (iterator.index ?? 0) + 1;
  const count = iterator.count ?? 0;

  const region = process.env.REGION;
  const fnArn = process.env.TARGET_LAMBDA_ARN;
  if (!region) throw new Error("REGION missing");
  if (!fnArn) throw new Error("TARGET_LAMBDA_ARN missing");

  const client = new LambdaClient({ region });
  await client.send(new InvokeCommand({
    FunctionName: fnArn,
    InvocationType: "Event"
  }));

  return {
    index,
    count,
    continue: index < count
  };
};
