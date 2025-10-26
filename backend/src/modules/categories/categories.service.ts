import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';

@Injectable()
export class CategoriesService {
  constructor(@InjectModel('Category') private categoryModel: Model<any>) {}

  async create(createCategoryDto: any) {
    const category = new this.categoryModel(createCategoryDto);
    return category.save();
  }

  async findAll() {
    return this.categoryModel.find().populate('parentId').exec();
  }

  async findById(id: string) {
    return this.categoryModel.findById(id).populate('parentId').exec();
  }

  async findChildren(parentId: string) {
    return this.categoryModel.find({ parentId }).exec();
  }

  async update(id: string, updateCategoryDto: any) {
    return this.categoryModel.findByIdAndUpdate(id, updateCategoryDto, { new: true }).exec();
  }

  async remove(id: string) {
    return this.categoryModel.findByIdAndDelete(id).exec();
  }
}
