'use client'

import { useContract, useContractWrite } from "@thirdweb-dev/react";
import { Button } from "@/components/ui/button";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import React from "react";

const addSchema = z.object({
  _cost: z.string().min(1),
  _maxTickets: z.number().min(1),
  _name: z.string().min(1),
  _imgUrl: z.string().min(1),
  _date: z.date(),
  _time: z.date(),
  _description: z.string().min(1),
  _location: z.string().min(1),
});

export default function Home() {
  const { contract } = useContract("0xc41e180eB7BDcF3A05893aEfA3dBc3e903A4b27d");
  const { mutateAsync: list, isLoading } = useContractWrite(contract, "list");
  const { register, handleSubmit, formState } = useForm({
    resolver: zodResolver(registerSchema),
  });

  const onSubmit = async (data) => {
    try {
      const contractResponse = await list(data);
      console.info("Contract call success", contractResponse);
    } catch (err) {
      console.error("Contract call failure", err);
    }
  };

  return (
    <div className="absolute -translate-x-1/2 -translate-y-1/2 top-1/2 left-1/2">
      <Card className="w-[350px]">
        <CardHeader>
          <CardTitle>Register</CardTitle>
          <CardDescription>Start the journey with us today.</CardDescription>
        </CardHeader>
        <CardContent>
          <Form onSubmit={handleSubmit(onSubmit)}>
            <div className="space-y-3">
              {/* _cost */}
              <FormField
                name="_cost"
                label="Cost"
                register={register}
                placeholder="Enter cost..."
              />
              {/* _maxTickets */}
              <FormField
                name="_maxTickets"
                label="Max Tickets"
                register={register}
                placeholder="Enter max tickets..."
              />
              {/* _name */}
              <FormField
                name="_name"
                label="Name"
                register={register}
                placeholder="Enter name..."
              />
              {/* _imgUrl */}
              <FormField
                name="_imgUrl"
                label="Image URL"
                register={register}
                placeholder="Enter image URL..."
              />
              {/* _date */}
              <FormField
                name="_date"
                label="Date"
                register={register}
                placeholder="Enter date..."
              />
              {/* _time */}
              <FormField
                name="_time"
                label="Time"
                register={register}
                placeholder="Enter time..."
              />
              {/* _description */}
              <FormField
                name="_description"
                label="Description"
                register={register}
                placeholder="Enter description..."
              />
              {/* _location */}
              <FormField
                name="_location"
                label="Location"
                register={register}
                placeholder="Enter location..."
              />
            </div>
            <div className="flex gap-2">
              <Button type="submit">Submit</Button>
            </div>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
}
