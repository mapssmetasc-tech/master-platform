import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class OrdersService {
  constructor(@InjectModel('Order') private orderModel: Model<any>) {}

  async create(createOrderDto: any) {
    const orderNumber = ORD-;
    const order = new this.orderModel({ ...createOrderDto, orderNumber });
    return order.save();
  }

  async findAll() {
    return this.orderModel.find().populate('customerId').exec();
  }

  async findById(id: string) {
    return this.orderModel.findById(id).populate('customerId').populate('items.productId').exec();
  }

  async findByCustomer(customerId: string) {
    return this.orderModel.find({ customerId }).sort({ createdAt: -1 }).exec();
  }

  async updateStatus(id: string, status: string) {
    return this.orderModel.findByIdAndUpdate(id, { status, updatedAt: new Date() }, { new: true }).exec();
  }

  async cancel(id: string) {
    return this.orderModel.findByIdAndUpdate(id, { status: 'cancelled', cancelledAt: new Date() }, { new: true }).exec();
  }
}
